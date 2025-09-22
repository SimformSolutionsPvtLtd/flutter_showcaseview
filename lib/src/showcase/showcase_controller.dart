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

import '../models/flutter_inherited_data.dart';
import '../models/linked_showcase_data_model.dart';
import '../models/tooltip_action_config.dart';
import '../tooltip/tooltip.dart';
import '../utils/overlay_manager.dart';
import '../utils/target_position_service.dart';
import '../widget/floating_action_widget.dart';
import '../widget/tooltip_action_button_widget.dart';
import 'showcase.dart';
import 'showcase_service.dart';
import 'showcase_view.dart';
import 'target_widget.dart';

/// Controller class for managing showcase functionality
///
/// This controller handles the lifecycle and presentation of a single
/// showcase element.
/// It manages the position, state, and rendering of showcase elements including
/// tooltips, target highlighting, and floating action widgets.
class ShowcaseController {
  /// Creates a [ShowcaseController] under the given [ShowcaseView.scope].
  ShowcaseController.register({
    required this.id,
    required this.key,
    required this.getState,
    required this.showcaseView,
  }) {
    ShowcaseService.instance.addController(
      controller: this,
      key: key,
      id: id,
      scope: showcaseView.scope,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _initRootWidget());
  }

  /// Unique identifier for the showcase.
  final int id;

  /// Global key associated with the showcase widget.
  final GlobalKey key;

  /// Configuration for the showcase.
  final ValueGetter<State<Showcase>> getState;

  /// Reference to the parent showcase widget state.
  ShowcaseView showcaseView;

  /// Position information for the showcase target.
  TargetPositionService? position;

  /// Data model for linked showcases.
  LinkedShowcaseDataModel? linkedShowcaseDataModel;

  /// Optional function to reverse the animation.
  ValueGetter<Future<void>>? reverseAnimationCallback;

  /// Size of the root widget.
  Size? rootWidgetSize;

  /// Render box for the root widget.
  RenderBox? rootRenderObject;

  /// List of tooltip widgets to be displayed.
  List<Widget> tooltipWidgets = [];

  /// Flag to track if scrolling is in progress.
  bool isScrollRunning = false;

  /// Blur effect value for the overlay background.
  double blur = 0;

  /// Global floating action widget to be displayed
  FloatingActionWidget? globalFloatingActionWidget;

  /// Captured inherited widget data from showcase context
  late final FlutterInheritedData inheritedData =
      FlutterInheritedData.fromContext(_context);

  /// Returns the Showcase widget configuration.
  ///
  /// Provides access to all properties and settings of the current showcase
  /// widget.
  /// This is used throughout the controller to access showcase configuration
  /// options.
  Showcase get config => getState().widget;

  /// Returns the BuildContext for this showcase.
  ///
  /// Used for positioning calculations and widget rendering. This context
  /// represents the location of the showcase target in the widget tree.
  BuildContext get _context => getState().context;

  /// Checks if the showcase context is still valid.
  ///
  /// Returns true if the context is mounted (valid) and false otherwise.
  /// Used to prevent operations on widgets that have been removed from the
  /// tree.
  bool get _mounted => getState().mounted;

  /// Callback to setup the showcase.
  ///
  /// Initializes the showcase by calculating positions and preparing visual
  /// elements.
  /// This method is called when a showcase is about to be displayed to
  /// ensure all positioning data is accurate and up-to-date.
  ///
  /// The method performs these key actions:
  /// - Exits early if showcases are disabled in the parent widget
  /// - Recalculates the root widget size to ensure accurate positioning
  /// - Sets up any global floating action widgets
  /// - Initializes position data if not already set
  ///
  /// This method is typically called internally by the showcase system but
  /// can also be called manually to force a recalculation of showcase elements.
  void setupShowcase({bool shouldUpdateOverlay = true}) {
    if (!showcaseView.enableShowcase || !_mounted) return;

    recalculateRootWidgetSize(
      _context,
      shouldUpdateOverlay: shouldUpdateOverlay,
    );
    globalFloatingActionWidget = showcaseView
        .getFloatingActionWidget(config.showcaseKey)
        ?.call(_context);
  }

  /// Used to scroll the target into view.
  ///
  /// Ensures the showcased widget is visible on screen by scrolling to it.
  /// This method handles the complete scrolling process including:
  ///
  /// - Setting visual indicators while scrolling is in progress
  /// - Updating the overlay to show loading state
  /// - Performing the actual scrolling operation
  /// - Refreshing the showcase display after scrolling completes
  /// - Manages the [isScrollRunning] state to coordinate UI updates.
  ///
  /// Note: Multi Showcase will not be scrolled into view!
  ///
  /// Returns a Future that completes when scrolling is finished. If the widget
  /// is unmounted during scrolling, the operation will be canceled safely.
  Future<void> scrollIntoView({bool shouldUpdateOverlay = true}) async {
    if (!_mounted) {
      assert(_mounted, 'Widget has been unmounted');
      return;
    }

    isScrollRunning = true;
    setupShowcase(shouldUpdateOverlay: shouldUpdateOverlay);
    await Scrollable.ensureVisible(
      _context,
      duration: showcaseView.scrollDuration,
      alignment: config.scrollAlignment,
    );

    isScrollRunning = false;
    setupShowcase(shouldUpdateOverlay: shouldUpdateOverlay);
  }

  /// Handles tap on barrier area.
  ///
  /// Respects [Showcase.disableBarrierInteraction] and [ShowcaseView
  /// .disableBarrierInteraction] settings.
  void handleBarrierTap() {
    config.onBarrierClick?.call();
    if (showcaseView.disableBarrierInteraction ||
        config.disableBarrierInteraction) {
      return;
    }
    _nextIfAny();
  }

  /// Updates root widget size and render object when the context changes.
  ///
  /// - Called during build to ensure showcase positioning is correct.
  /// - Recalculates sizes, updates controller data, and triggers overlay
  /// updates.
  ///
  /// Parameter:
  /// * [context] The BuildContext of the [Showcase] widget.
  void recalculateRootWidgetSize(
    BuildContext context, {
    bool shouldUpdateOverlay = true,
  }) {
    if (!showcaseView.enableShowcase || !showcaseView.isShowcaseRunning) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted ||
          !showcaseView.enableShowcase ||
          !showcaseView.isShowcaseRunning) {
        return;
      }

      _initRootWidget();

      if (shouldUpdateOverlay) {
        OverlayManager.instance.update(
          show: showcaseView.isShowcaseRunning,
          scope: showcaseView.scope,
        );
      }
    });
  }

  /// Updates the controller's data when the showcase position or size
  /// changes. Rebuilds the showcase overlay with updated positioning
  /// information.
  ///
  /// Another use of this is to update the controller data just before
  /// overlay is inserted so we can get the correct position. Which is need in
  /// page transition case where page transition may take some time to reach
  /// to it's original position.
  void updateControllerData() {
    if (!_mounted) return;
    final renderBox = _context.findRenderObject() as RenderBox?;
    final screenSize = MediaQuery.sizeOf(_context);
    final size = rootWidgetSize ?? screenSize;
    final newPosition = TargetPositionService(
      rootRenderObject: rootRenderObject,
      screenSize: size,
      renderBox: renderBox,
      padding: config.targetPadding,
    );

    position = newPosition;
    final rect = newPosition.getRectForOverlay();
    linkedShowcaseDataModel = LinkedShowcaseDataModel(
      rect: isScrollRunning ? Rect.zero : rect,
      radius: config.targetBorderRadius,
      overlayPadding: isScrollRunning ? EdgeInsets.zero : config.targetPadding,
      isCircle: config.targetShapeBorder is CircleBorder,
    );

    _buildOverlayOnTarget(
      offset: newPosition.getOffset(),
      size: rect.size,
      rectBound: rect,
      screenSize: size,
    );
  }

  /// Initializes the root widget size and render object.
  ///
  /// Must be called after the widget is mounted to ensure proper measurements.
  void _initRootWidget() {
    final rootWidget = _context.findRootAncestorStateOfType<State<Overlay>>();
    rootRenderObject = rootWidget?.context.findRenderObject() as RenderBox?;
    rootWidgetSize = rootWidget == null
        ? MediaQuery.sizeOf(_context)
        : rootRenderObject?.size;
  }

  /// Builds the overlay widgets for the target widget.
  ///
  /// Includes target highlight, tooltip, and optional floating action widget.
  /// Creates different widget sets based on whether scrolling is in progress.
  ///
  /// * [offset] The position offset of the target.
  /// * [size] The size of the target.
  /// * [rectBound] The target's bounding rectangle.
  /// * [screenSize] The current screen size.
  void _buildOverlayOnTarget({
    required Offset offset,
    required Size size,
    required Rect rectBound,
    required Size screenSize,
  }) {
    blur = kIsWeb ? 0.0 : max(0, config.blurValue ?? showcaseView.blurValue);

    tooltipWidgets = isScrollRunning
        ? [Center(child: config.scrollLoadingWidget)]
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
              arrowAlignment: config.arrowAlignment,
              onTooltipTap: config.disposeOnTap ?? config.onToolTipClick != null
                  ? _getOnTooltipTap
                  : null,
              tooltipPadding: config.tooltipPadding,
              disableMovingAnimation: config.disableMovingAnimation ??
                  showcaseView.disableMovingAnimation,
              disableScaleAnimation: (config.disableScaleAnimation ??
                      showcaseView.disableScaleAnimation) ||
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
              targetTooltipGap: config.targetTooltipGap,
              showcaseController: this,
            ),
            if (_getFloatingActionWidget case final floatAction?) floatAction,
          ];
  }

  /// Moves to the next showcase if any are remaining. Called when a showcase
  /// step is completed. Notifies the showcase widget state to advance to the
  /// next showcase.
  void _nextIfAny() {
    if (showcaseView.isShowCaseCompleted) return;
    showcaseView.completed(config.showcaseKey);
  }

  /// Handles target tap behavior based on configuration.
  ///
  /// If [Showcase.disposeOnTap] is true, dismisses the entire showcase,
  /// otherwise advances.
  void _getOnTargetTap() {
    if (config.disposeOnTap ?? false) {
      showcaseView.dismiss();
      assert(
        config.onTargetClick != null,
        'onTargetClick callback should be provided when disposeOnTap is true',
      );
      config.onTargetClick?.call();
    } else {
      (config.onTargetClick ?? _nextIfAny).call();
    }
  }

  /// Handles tooltip tap behavior based on configuration.
  ///
  /// If [Showcase.disposeOnTap] is true, dismisses the entire showcase before
  /// executing callback.
  void _getOnTooltipTap() {
    if (config.disposeOnTap ?? false) showcaseView.dismiss();
    config.onToolTipClick?.call();
  }

  /// Retrieves tooltip action widgets based on configuration.
  ///
  /// Filters actions that should be hidden for the current showcase.
  /// Assembles action widgets with appropriate spacing and configuration.
  ///
  /// @return List of tooltip action widgets
  List<Widget> _getTooltipActions() {
    final doesHaveLocalActions = config.tooltipActions != null;
    final actionData = doesHaveLocalActions
        ? config.tooltipActions!
        : showcaseView.globalTooltipActions ?? [];
    final actionDataLength = actionData.length;
    final lastAction = actionData.lastOrNull;
    final actionGap = _getTooltipActionConfig().actionGap;

    return [
      for (var i = 0; i < actionDataLength; i++)
        if (doesHaveLocalActions ||
            !actionData[i]
                .hideActionWidgetForShowcase
                .contains(config.showcaseKey))
          Padding(
            padding: EdgeInsetsDirectional.only(
              end: actionData[i] == lastAction ? 0 : actionGap,
            ),
            child: TooltipActionButtonWidget(
              config: actionData[i],
              showCaseState: showcaseView,
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
        showcaseView.globalTooltipActionConfig ??
        const TooltipActionConfig();
  }

  /// Retrieves the floating action widget if available. Prefers local
  /// configuration over global when available.
  FloatingActionWidget? get _getFloatingActionWidget =>
      config.floatingActionWidget ?? globalFloatingActionWidget;

  @override
  int get hashCode => Object.hash(id, key);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ShowcaseController && other.key == key && other.id == id;
  }
}
