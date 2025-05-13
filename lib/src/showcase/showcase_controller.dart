/*
 * Copyright (c) 2021 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../get_position.dart';
import '../models/linked_showcase_data.dart';
import '../models/tooltip_action_config.dart';
import '../overlay_manager.dart';
import '../showcase_service.dart';
import '../showcase_view.dart';
import '../tooltip/tooltip.dart';
import '../tooltip_action_button_widget.dart';
import '../widget/floating_action_widget.dart';
import 'showcase.dart';
import 'target_widget.dart';

/// Controller class for managing showcase functionality
///
/// This controller handles the lifecycle and presentation of a single showcase element.
/// It manages the position, state, and rendering of showcase elements including
/// tooltips, target highlighting, and floating action widgets.
class ShowcaseController {
  /// Creates a [ShowcaseController] with required parameters
  ///
  /// * [id] - Unique identifier for this showcase instance
  /// * [key] - Global key associated with the showcase widget
  /// * [getState] - Reference to the showcase state
  /// * [showCaseView] - Reference to the parent showcase view
  ShowcaseController({
    required this.id,
    required this.key,
    required this.getState,
    required this.showCaseView,
  }) {
    ShowcaseService.instance.registerController(
      controller: this,
      key: key,
      id: id,
      scope: showCaseView.scope,
    );
    initRootWidget();
  }

  /// Unique identifier for the showcase
  final int id;

  /// Global key associated with the showcase widget
  final GlobalKey key;

  /// Configuration for the showcase
  final ValueGetter<State<Showcase>> getState;

  /// Reference to the parent showcase widget state
  ShowcaseView showCaseView;

  /// Position information for the showcase target
  GetPosition? position;

  /// Data model for linked showcases
  LinkedShowcaseDataModel? linkedShowcaseDataModel;

  /// Optional function to reverse the animation
  ValueGetter<Future<void>>? reverseAnimationCallback;

  /// Size of the root widget
  Size? rootWidgetSize;

  /// Render box for the root widget
  RenderBox? rootRenderObject;

  /// List of tooltip widgets to be displayed
  List<Widget> getToolTipWidget = [];

  /// Flag to track if scrolling is in progress
  bool isScrollRunning = false;

  /// Blur effect value for the overlay background
  double blur = 0.0;

  /// Global floating action widget to be displayed
  FloatingActionWidget? globalFloatingActionWidget;

  /// Returns the Showcase widget configuration
  ///
  /// Provides access to all properties and settings of the current showcase widget.
  /// This is used throughout the controller to access showcase configuration options.
  Showcase get config => getState().widget;

  /// Returns the BuildContext for this showcase
  ///
  /// Used for positioning calculations and widget rendering.
  /// This context represents the location of the showcase target in the widget tree.
  BuildContext get _context => getState().context;

  /// Checks if the showcase context is still valid
  ///
  /// Returns true if the context is mounted (valid) and false otherwise.
  /// Used to prevent operations on widgets that have been removed from the tree.
  bool get _mounted => getState().mounted;

  /// Initializes the root widget size and render object
  ///
  /// Must be called after the widget is mounted to ensure proper measurements.
  /// Uses a post-frame callback to capture accurate widget dimensions.
  void initRootWidget() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rootWidget = _context.findRootAncestorStateOfType<State<Overlay>>();
      rootRenderObject = rootWidget?.context.findRenderObject() as RenderBox?;
      rootWidgetSize = rootWidget == null
          ? MediaQuery.of(_context).size
          : rootRenderObject?.size;
    });
  }

  /// Updates root widget size and render object when the context changes
  ///
  /// Called during build to ensure showcase positioning is correct.
  /// Recalculates sizes, updates controller data, and triggers overlay updates.
  /// mounted check ensure the context is still valid before proceeding.
  /// * [context] The BuildContext of the showcase widget
  void recalculateRootWidgetSize(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final rootWidget = context.findRootAncestorStateOfType<State<Overlay>>();
      rootRenderObject = rootWidget?.context.findRenderObject() as RenderBox?;
      rootWidgetSize = rootWidget == null
          ? MediaQuery.of(context).size
          : rootRenderObject?.size;
      if (!showCaseView.enableShowcase) return;
      updateControllerData();
      if (!showCaseView.isShowcaseRunning) return;
      OverlayManager.instance.update(
        show: showCaseView.isShowcaseRunning,
        scope: showCaseView.scope,
      );
    });
  }

  /// Updates the controller's data when the showcase position or size changes
  ///
  /// Rebuilds the showcase overlay with updated positioning information.
  /// Creates positioning data and updates the visual representation.
  ///
  /// Another use of this is to update the controller data just before overlay is
  /// inserted so we can get the correct position. Which is need in
  /// page transition case where page transition may take some time to reach
  /// to it's original position
  void updateControllerData() {
    if (!_mounted) return;
    final renderBox = _context.findRenderObject() as RenderBox?;
    final screenSize = MediaQuery.of(_context).size;
    final size = rootWidgetSize ?? screenSize;
    final newPosition = GetPosition(
      rootRenderObject: rootRenderObject,
      renderBox: renderBox,
      padding: config.targetPadding,
      screenWidth: size.width,
      screenHeight: size.height,
    );

    position = newPosition;
    final rect = newPosition.getRectForOverlay();
    linkedShowcaseDataModel = LinkedShowcaseDataModel(
      rect: isScrollRunning ? Rect.zero : rect,
      radius: config.targetBorderRadius,
      overlayPadding: isScrollRunning ? EdgeInsets.zero : config.targetPadding,
      isCircle: config.targetShapeBorder is CircleBorder,
    );

    buildOverlayOnTarget(
      offset: newPosition.getOffset(),
      size: rect.size,
      rectBound: rect,
      screenSize: size,
    );
  }

  /// Builds the overlay widgets for the target widget
  ///
  /// Includes target highlight, tooltip, and optional floating action widget.
  /// Creates different widget sets based on whether scrolling is in progress.
  ///
  /// * [offset] The position offset of the target
  /// * [size] The size of the target
  /// * [rectBound] The target's bounding rectangle
  /// * [screenSize] The current screen size
  void buildOverlayOnTarget({
    required Offset offset,
    required Size size,
    required Rect rectBound,
    required Size screenSize,
  }) {
    blur = kIsWeb ? 0.0 : max(0.0, config.blurValue ?? showCaseView.blurValue);

    getToolTipWidget = isScrollRunning
        ? [
            Center(child: config.scrollLoadingWidget),
          ]
        : [
            TargetWidget(
              offset: rectBound.topLeft,
              size: size,
              onTap: _getOnTargetTap,
              radius: config.targetBorderRadius,
              onDoubleTap: config.onTargetDoubleTap,
              onLongPress: config.onTargetLongPress,
              shapeBorder: config.targetShapeBorder,
              disableDefaultChildGestures: config.disableDefaultTargetGestures,
              targetPadding: config.targetPadding,
            ),
            ToolTipWidget(
              key: ValueKey(id),
              title: config.title,
              titleTextAlign: config.titleTextAlign,
              description: config.description,
              descriptionTextAlign: config.descriptionTextAlign,
              titleAlignment: config.titleAlignment,
              descriptionAlignment: config.descriptionAlignment,
              titleTextStyle: config.titleTextStyle,
              descTextStyle: config.descTextStyle,
              container: config.container,
              tooltipBackgroundColor: config.tooltipBackgroundColor,
              textColor: config.textColor,
              showArrow: config.showArrow,
              onTooltipTap:
                  config.disposeOnTap == true || config.onToolTipClick != null
                      ? _getOnTooltipTap
                      : null,
              tooltipPadding: config.tooltipPadding,
              disableMovingAnimation: config.disableMovingAnimation ??
                  showCaseView.disableMovingAnimation,
              disableScaleAnimation: (config.disableScaleAnimation ??
                      showCaseView.disableScaleAnimation) ||
                  config.container != null,
              movingAnimationDuration: config.movingAnimationDuration,
              tooltipBorderRadius: config.tooltipBorderRadius,
              scaleAnimationDuration: config.scaleAnimationDuration,
              scaleAnimationCurve: config.scaleAnimationCurve,
              scaleAnimationAlignment: config.scaleAnimationAlignment,
              tooltipPosition: config.tooltipPosition,
              titlePadding: config.titlePadding,
              descriptionPadding: config.descriptionPadding,
              titleTextDirection: config.titleTextDirection,
              descriptionTextDirection: config.descriptionTextDirection,
              toolTipSlideEndDistance: config.toolTipSlideEndDistance,
              toolTipMargin: config.toolTipMargin,
              tooltipActionConfig: _getTooltipActionConfig(),
              tooltipActions: _getTooltipActions(),
              targetPadding: config.targetPadding,
              showcaseController: this,
            ),
            if (_getFloatingActionWidget != null) _getFloatingActionWidget!,
          ];
  }

  /// Callback to start the showcase
  ///
  /// Initializes the showcase by calculating positions and preparing visual elements.
  /// This method is called when a showcase is about to be displayed to ensure all
  /// positioning data is accurate and up-to-date.
  ///
  /// The method performs these key actions:
  /// - Exits early if showcases are disabled in the parent widget
  /// - Recalculates the root widget size to ensure accurate positioning
  /// - Sets up any global floating action widgets
  /// - Initializes position data if not already set
  ///
  /// This method is typically called internally by the showcase system but
  /// can also be called manually to force a recalculation of showcase elements.
  void startShowcase() {
    if (!showCaseView.enableShowcase || !_mounted) return;

    recalculateRootWidgetSize(_context);
    globalFloatingActionWidget = showCaseView
        .getFloatingActionWidget(config.showcaseKey)
        ?.call(_context);
    final size = rootWidgetSize ?? MediaQuery.of(_context).size;
    position ??= GetPosition(
      rootRenderObject: rootRenderObject,
      renderBox: _context.findRenderObject() as RenderBox?,
      padding: config.targetPadding,
      screenWidth: size.width,
      screenHeight: size.height,
    );
  }

  /// Used to scroll the target into view
  ///
  /// Ensures the showcased widget is visible on screen by scrolling to it.
  /// This method handles the complete scrolling process including:
  ///
  /// - Setting visual indicators while scrolling is in progress
  /// - Updating the overlay to show loading state
  /// - Performing the actual scrolling operation
  /// - Refreshing the showcase display after scrolling completes
  ///
  /// The method shows a loading indicator during scrolling and updates
  /// the showcase position after scrolling completes. It manages the
  /// `isScrollRunning` state to coordinate UI updates.
  ///
  /// Note: Multi Showcase will not be scrolled into view
  ///
  /// Returns a Future that completes when scrolling is finished. If the widget
  /// is unmounted during scrolling, the operation will be canceled safely.
  Future<void> scrollIntoView() async {
    if (!_mounted) {
      assert(_mounted, 'Widget has been unmounted');
      return;
    }

    isScrollRunning = true;
    updateControllerData();
    startShowcase();
    OverlayManager.instance.update(
      show: showCaseView.isShowcaseRunning,
      scope: showCaseView.scope,
    );
    await Scrollable.ensureVisible(
      _context,
      duration: showCaseView.scrollDuration,
      alignment: config.scrollAlignment,
    );

    isScrollRunning = false;
    updateControllerData();
    startShowcase();
    OverlayManager.instance.update(
      show: showCaseView.isShowcaseRunning,
      scope: showCaseView.scope,
    );
  }

  /// Moves to the next showcase if any are remaining
  ///
  /// Called when a showcase is completed.
  /// Notifies the showcase widget state to advance to the next showcase.
  void _nextIfAny() {
    if (showCaseView.isShowCaseCompleted) return;
    showCaseView.completed(config.showcaseKey);
  }

  /// Handles target tap behavior based on configuration
  ///
  /// Either dismisses the showcase or moves to the next step based on configuration.
  /// If [disposeOnTap] is true, dismisses the entire showcase, otherwise advances.
  void _getOnTargetTap() {
    if (config.disposeOnTap == true) {
      showCaseView.dismiss();
      assert(
        config.onTargetClick != null,
        'onTargetClick callback should be provided when disposeOnTap is true',
      );
      config.onTargetClick!();
    } else {
      (config.onTargetClick ?? _nextIfAny).call();
    }
  }

  /// Handles tooltip tap behavior based on configuration
  ///
  /// Dismisses the showcase if configured to do so, and executes any configured callback.
  /// If [disposeOnTap] is true, dismisses the entire showcase before executing callback.
  void _getOnTooltipTap() {
    if (config.disposeOnTap == true) {
      showCaseView.dismiss();
    }
    config.onToolTipClick?.call();
  }

  /// Retrieves tooltip action widgets based on configuration
  ///
  /// Filters actions that should be hidden for the current showcase.
  /// Assembles action widgets with appropriate spacing and configuration.
  ///
  /// @return List of tooltip action widgets
  List<Widget> _getTooltipActions() {
    final doesHaveLocalActions = config.tooltipActions != null;
    final actionData = doesHaveLocalActions
        ? config.tooltipActions!
        : showCaseView.globalTooltipActions ?? [];
    final actionDataLength = actionData.length;

    return [
      for (var i = 0; i < actionDataLength; i++)
        if (doesHaveLocalActions ||
            !actionData[i]
                .hideActionWidgetForShowcase
                .contains(config.showcaseKey))
          Padding(
            padding: EdgeInsetsDirectional.only(
              end: actionData[i] == actionData.last
                  ? 0
                  : _getTooltipActionConfig().actionGap,
            ),
            child: TooltipActionButtonWidget(
              config: actionData[i],
              // We have to pass showcaseState from here because
              // [TooltipActionButtonWidget] is not direct child of showcaseWidget
              // so it won't be able to get the state by using it's context
              showCaseState: showCaseView,
            ),
          ),
    ];
  }

  /// Gets the tooltip action configuration
  ///
  /// Uses local config if available, falls back to global config or default.
  /// Provides a consistent approach to configuration priority.
  ///
  /// @return The tooltip action configuration to use
  TooltipActionConfig _getTooltipActionConfig() {
    return config.tooltipActionConfig ??
        showCaseView.globalTooltipActionConfig ??
        const TooltipActionConfig();
  }

  /// Retrieves the floating action widget if available
  ///
  /// Combines local widget with global floating action widget.
  /// Prefers local configuration over global when available.
  ///
  /// @return The floating action widget or null if none is configured
  Widget? get _getFloatingActionWidget =>
      config.floatingActionWidget ?? globalFloatingActionWidget;

  @override
  int get hashCode => Object.hash(id, key);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ShowcaseController && other.key == key && other.id == id;
  }
}
