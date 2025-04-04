import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../get_position.dart';
import '../models/linked_showcase_data.dart';
import '../models/tooltip_action_config.dart';
import '../showcase_widget.dart';
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
  /// * [config] - Configuration settings for the showcase
  /// * [showCaseWidgetState] - Reference to the parent showcase widget state
  /// * [scrollIntoViewCallback] - Optional callback to scroll the target into view
  ShowcaseController({
    required this.id,
    required this.key,
    required this.config,
    required this.showCaseWidgetState,
    required this.updateControllerValue,
    this.scrollIntoViewCallback,
  }) {
    showCaseWidgetState.registerShowcaseController(
      controller: this,
      key: key,
      showcaseId: id,
    );
    initRootWidget();
  }

  /// Unique identifier for the showcase
  final int id;

  /// Global key associated with the showcase widget
  final GlobalKey key;

  /// Configuration for the showcase
  Showcase config;

  /// Reference to the parent showcase widget state
  ShowCaseWidgetState showCaseWidgetState;

  /// Position information for the showcase target
  GetPosition? position;

  /// Data model for linked showcases
  LinkedShowcaseDataModel? linkedShowcaseDataModel;

  /// Callback to start the showcase
  VoidCallback? startShowcase;

  /// Optional function to scroll the target into view
  final ValueGetter<Future<void>>? scrollIntoViewCallback;

  /// Optional function to reverse the animation
  ValueGetter<Future<void>>? reverseAnimationCallback;

  /// Function to update the controller value
  ///
  /// Main use of this is to update the controller data just before overlay is
  /// inserted so we can get the correct position. Which is need in
  /// page transition case where page transition may take some time to reach
  /// to it's original position
  VoidCallback updateControllerValue;

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

  /// Initializes the root widget size and render object
  ///
  /// Must be called after the widget is mounted to ensure proper measurements.
  /// Uses a post-frame callback to capture accurate widget dimensions.
  void initRootWidget() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      rootWidgetSize = showCaseWidgetState.rootWidgetSize;
      rootRenderObject = showCaseWidgetState.rootRenderObject;
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
      if (!showCaseWidgetState.enableShowcase) return;
      updateControllerData(
        context.findRenderObject() as RenderBox?,
        MediaQuery.of(context).size,
      );
      showCaseWidgetState.updateOverlay?.call(
        showCaseWidgetState.isShowcaseRunning,
      );
    });
  }

  /// Updates the controller's data when the showcase position or size changes
  ///
  /// Rebuilds the showcase overlay with updated positioning information.
  /// Creates positioning data and updates the visual representation.
  ///
  /// * [renderBox] The RenderBox of the target widget
  /// * [screenSize] The current screen size
  void updateControllerData(
    RenderBox? renderBox,
    Size screenSize,
  ) {
    final size = rootWidgetSize ?? screenSize;
    final newPosition = GetPosition(
      rootRenderObject: rootRenderObject,
      renderBox: renderBox,
      padding: config.targetPadding,
      screenWidth: size.width,
      screenHeight: size.height,
    );

    position = newPosition;
    final rect = newPosition.getRect();
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
    blur = kIsWeb
        ? 0.0
        : max(0.0, config.blurValue ?? showCaseWidgetState.blurValue);

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
                  showCaseWidgetState.disableMovingAnimation,
              disableScaleAnimation: (config.disableScaleAnimation ??
                      showCaseWidgetState.disableScaleAnimation) ||
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

  /// Moves to the next showcase if any are remaining
  ///
  /// Called when a showcase is completed.
  /// Notifies the showcase widget state to advance to the next showcase.
  void _nextIfAny() {
    if (showCaseWidgetState.isShowCaseCompleted) return;
    showCaseWidgetState.completed(config.showcaseKey);
  }

  /// Handles target tap behavior based on configuration
  ///
  /// Either dismisses the showcase or moves to the next step based on configuration.
  /// If [disposeOnTap] is true, dismisses the entire showcase, otherwise advances.
  void _getOnTargetTap() {
    if (config.disposeOnTap == true) {
      showCaseWidgetState.dismiss();
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
      showCaseWidgetState.dismiss();
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
    final doesHaveLocalActions = config.tooltipActions?.isNotEmpty ?? false;
    final actionData = doesHaveLocalActions
        ? config.tooltipActions!
        : showCaseWidgetState.globalTooltipActions ?? [];
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
              showCaseState: showCaseWidgetState,
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
        showCaseWidgetState.globalTooltipActionConfig ??
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
