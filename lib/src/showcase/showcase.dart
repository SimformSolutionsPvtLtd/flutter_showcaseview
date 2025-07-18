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

import 'package:flutter/material.dart';

import '../models/showcase_scope.dart';
import '../models/tooltip_action_button.dart';
import '../models/tooltip_action_config.dart';
import '../utils/constants.dart';
import '../utils/enum.dart';
import '../utils/overlay_manager.dart';
import '../widget/floating_action_widget.dart';
import 'showcase_controller.dart';
import 'showcase_service.dart';

/// A widget that highlights a specific widget on the screen with an
/// informative message to guide the user.
class Showcase extends StatefulWidget {
  /// Creates a showcase widget with standard tooltip.
  ///
  /// This constructor creates a showcase widget with a default tooltip that
  /// displays a title and description. It's used to highlight specific
  /// widgets within your app and provide explanatory text to guide users.
  ///
  /// The showcase creates a visually distinct highlighting effect around the
  /// target [child] widget and displays an informative tooltip. When
  /// combined with [ShowcaseView], multiple showcases can be sequenced to
  /// create a guided tour of your app's features.
  ///
  /// Example usage:
  /// ```dart
  /// Showcase(
  ///   key: _myShowcaseKey,
  ///   title: 'Profile',
  ///   description: 'Tap to view your profile details',
  ///   child: IconButton(
  ///     icon: Icon(Icons.person),
  ///     onPressed: () {},
  ///   ),
  /// )
  /// ```
  const Showcase({
    required GlobalKey key,
    required this.description,
    required this.child,
    this.title,
    this.titleTextAlign = TextAlign.start,
    this.descriptionTextAlign = TextAlign.start,
    this.titleAlignment = Alignment.center,
    this.descriptionAlignment = Alignment.center,
    this.targetShapeBorder = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    this.overlayColor = Colors.black45,
    this.overlayOpacity = 0.75,
    this.titleTextStyle,
    this.descTextStyle,
    this.tooltipBackgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.scrollLoadingWidget = Constants.defaultProgressIndicator,
    this.showArrow = true,
    this.onTargetClick,
    this.disposeOnTap,
    this.autoPlayDelay,
    this.movingAnimationDuration = const Duration(milliseconds: 2000),
    this.disableMovingAnimation,
    this.disableScaleAnimation,
    this.tooltipPadding =
        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    this.onToolTipClick,
    this.targetPadding = EdgeInsets.zero,
    this.blurValue,
    this.targetBorderRadius,
    this.onTargetLongPress,
    this.onTargetDoubleTap,
    this.tooltipBorderRadius,
    this.disableDefaultTargetGestures = false,
    this.scaleAnimationDuration = const Duration(milliseconds: 300),
    this.scaleAnimationCurve = Curves.easeIn,
    this.scaleAnimationAlignment,
    this.tooltipPosition,
    this.titlePadding,
    this.descriptionPadding,
    this.titleTextDirection,
    this.descriptionTextDirection,
    this.onBarrierClick,
    this.disableBarrierInteraction = false,
    this.toolTipSlideEndDistance = 7,
    this.toolTipMargin = 14,
    this.tooltipActions,
    this.tooltipActionConfig,
    this.scrollAlignment = 0.5,
    this.enableAutoScroll,
    this.floatingActionWidget,
    this.targetTooltipGap = 10,
  })  : height = null,
        width = null,
        container = null,
        showcaseKey = key,
        assert(
          targetTooltipGap >= 0,
          'targetTooltipGap must be greater than 0',
        ),
        assert(
          overlayOpacity >= 0.0 && overlayOpacity <= 1.0,
          'overlay opacity must be between 0 and 1.',
        ),
        assert(
          onTargetClick == null || disposeOnTap != null,
          "`disposeOnTap` is required if you're using `onTargetClick`",
        ),
        assert(
          disposeOnTap == null || onTargetClick != null,
          "`onTargetClick` is required if you're using `disposeOnTap`",
        ),
        assert(
          onBarrierClick == null || disableBarrierInteraction == false,
          "can't use `onBarrierClick` & `disableBarrierInteraction` property "
          'at same time',
        );

  /// Creates a showcase with a completely custom tooltip widget.
  ///
  /// Unlike the standard constructor, this constructor allows you to provide
  /// your own custom widget to use as the tooltip through the [container]
  /// parameter. This gives you full control over the tooltip's appearance.
  ///
  /// Use this constructor when you need a tooltip design that can't be achieved
  /// with the standard title/description format, such as including images,
  /// interactive elements, or complex layouts in your tooltip.
  ///
  /// Example usage:
  /// ```dart
  /// Showcase.withWidget(
  ///   key: _customKey,
  ///   height: 80,
  ///   width: 140,
  ///   container: Column(
  ///     children: [
  ///       Text(
  ///         "This is a custom widget!",
  ///         style: TextStyle(color: Colors.white),
  ///       ),
  ///       SizedBox(height: 10),
  ///       Image.asset('assets/tutorial_image.png', width: 100),
  ///     ],
  ///   ),
  ///   child: FloatingActionButton(
  ///     onPressed: () {},
  ///     child: Icon(Icons.add),
  ///   ),
  /// )
  /// ```
  const Showcase.withWidget({
    required GlobalKey key,
    required this.height,
    required this.width,
    required this.container,
    required this.child,
    this.floatingActionWidget,
    this.targetShapeBorder = Constants.defaultTargetShapeBorder,
    this.overlayColor = Colors.black45,
    this.targetBorderRadius,
    this.overlayOpacity = 0.75,
    this.scrollLoadingWidget = Constants.defaultProgressIndicator,
    this.onTargetClick,
    this.disposeOnTap,
    this.autoPlayDelay,
    this.movingAnimationDuration = Constants.defaultAnimationDuration,
    this.disableMovingAnimation,
    this.targetPadding = EdgeInsets.zero,
    this.blurValue,
    this.onTargetLongPress,
    this.onTargetDoubleTap,
    this.disableDefaultTargetGestures = false,
    this.tooltipPosition,
    this.onBarrierClick,
    this.disableBarrierInteraction = false,
    this.toolTipSlideEndDistance = 7,
    this.tooltipActions,
    this.tooltipActionConfig,
    this.scrollAlignment = 0.5,
    this.enableAutoScroll,
    this.toolTipMargin = 14,
    this.targetTooltipGap = 10,
  })  : showArrow = false,
        onToolTipClick = null,
        scaleAnimationDuration = const Duration(milliseconds: 300),
        scaleAnimationCurve = Curves.decelerate,
        scaleAnimationAlignment = null,
        disableScaleAnimation = null,
        title = null,
        description = null,
        titleTextAlign = TextAlign.start,
        descriptionTextAlign = TextAlign.start,
        titleAlignment = Alignment.center,
        descriptionAlignment = Alignment.center,
        titleTextStyle = null,
        descTextStyle = null,
        tooltipBackgroundColor = Colors.white,
        textColor = Colors.black,
        tooltipBorderRadius = null,
        tooltipPadding = const EdgeInsets.symmetric(vertical: 8),
        titlePadding = null,
        descriptionPadding = null,
        titleTextDirection = null,
        descriptionTextDirection = null,
        showcaseKey = key,
        assert(
          targetTooltipGap >= 0,
          'targetTooltipGap must be greater than 0',
        ),
        assert(
          overlayOpacity >= 0.0 && overlayOpacity <= 1.0,
          'overlay opacity must be between 0 and 1.',
        ),
        assert(
          onTargetClick == null || disposeOnTap != null,
          "`disposeOnTap` is required if you're using `onTargetClick`",
        ),
        assert(
          disposeOnTap == null || onTargetClick != null,
          "`onTargetClick` is required if you're using `disposeOnTap`",
        ),
        assert(
          onBarrierClick == null || disableBarrierInteraction == false,
          "can't use `onBarrierClick` & `disableBarrierInteraction` property "
          'at same time',
        );

  /// A key that is unique across the entire app.
  ///
  /// This Key will be used to control state of individual showcase and also
  /// used in [ShowcaseView.setupShowcase] to define position of current
  /// target widget while showcasing.
  final GlobalKey showcaseKey;

  /// Target widget that will be showcased or highlighted
  final Widget child;

  /// Represents subject line of target widget
  final String? title;

  /// Represents summary description of target widget
  final String? description;

  /// ShapeBorder of the highlighted box when target widget will be showcased.
  ///
  /// Note: If [targetBorderRadius] is specified, this parameter will be
  /// ignored.
  ///
  /// Default value is:
  /// ```dart
  /// RoundedRectangleBorder(
  ///   borderRadius: BorderRadius.all(Radius.circular(8)),
  /// ),
  /// ```
  final ShapeBorder targetShapeBorder;

  /// Radius of rectangle box while target widget is being showcased.
  ///
  /// Default value is:
  /// ```dart
  /// const Radius.circular(3.0),
  /// ```
  final BorderRadius? targetBorderRadius;

  /// TextStyle for default tooltip title
  final TextStyle? titleTextStyle;

  /// TextStyle for default tooltip description
  final TextStyle? descTextStyle;

  /// Empty space around tooltip content.
  ///
  /// Default Value for [Showcase] widget is:
  /// ```dart
  /// EdgeInsets.symmetric(vertical: 8, horizontal: 8)
  /// ```
  final EdgeInsets tooltipPadding;

  /// Background color of overlay during showcase.
  ///
  /// Default value is [Colors.black45]
  final Color overlayColor;

  /// Opacity apply on [overlayColor] (which ranges from 0.0 to 1.0)
  ///
  /// Default to 0.75
  final double overlayOpacity;

  /// Custom tooltip widget when [Showcase.withWidget] is used.
  final Widget? container;

  /// Custom static floating action widget to show a static widget anywhere
  /// on the screen
  final FloatingActionWidget? floatingActionWidget;

  /// Defines background color for tooltip widget.
  ///
  /// Default to [Colors.white]
  final Color tooltipBackgroundColor;

  /// Defines text color of default tooltip when [titleTextStyle] and
  /// [descTextStyle] is not provided.
  ///
  /// Default to [Colors.black]
  final Color textColor;

  /// If [enableAutoScroll] is sets to `true`, this widget will be shown above
  /// the overlay until the target widget is visible in the viewport.
  final Widget scrollLoadingWidget;

  /// Whether the default tooltip will have arrow to point out the target
  /// widget.
  ///
  /// Default to `true`
  final bool showArrow;

  /// Height of [container]
  final double? height;

  /// Width of [container]
  final double? width;

  /// The duration of time the bouncing animation of tooltip should last.
  ///
  /// Default to [Duration(milliseconds: 2000)]
  final Duration movingAnimationDuration;

  /// The delay before the next play start.
  final Duration? autoPlayDelay;

  /// Triggered when default tooltip is tapped
  final VoidCallback? onToolTipClick;

  /// Triggered when showcased target widget is tapped
  ///
  /// Note: [disposeOnTap] is required if you're using [onTargetClick]
  /// otherwise throws error
  final VoidCallback? onTargetClick;

  /// Will dispose all showcases if tapped on target widget or tooltip
  ///
  /// Note: [onTargetClick] is required if you're using [disposeOnTap]
  /// otherwise throws error
  final bool? disposeOnTap;

  /// Whether tooltip should have bouncing animation while showcasing
  ///
  /// If null value is provided,
  /// [ShowCaseWidget.disableAnimation] will be considered.
  final bool? disableMovingAnimation;

  /// Whether disabling initial scale animation for default tooltip when
  /// showcase is started and completed
  ///
  /// Default to `false`
  final bool? disableScaleAnimation;

  /// Padding around target widget
  ///
  /// Default to [EdgeInsets.zero]
  final EdgeInsets targetPadding;

  /// Triggered when target has been double tapped
  final VoidCallback? onTargetDoubleTap;

  /// Triggered when target has been long pressed.
  ///
  /// Detected when a pointer has remained in contact with the screen at the
  /// same location for a long period of time.
  final VoidCallback? onTargetLongPress;

  /// Border Radius of default tooltip
  ///
  /// Default to [BorderRadius.circular(8)]
  final BorderRadius? tooltipBorderRadius;

  /// if `disableDefaultTargetGestures` parameter is true
  /// onTargetClick, onTargetDoubleTap, onTargetLongPress and
  /// disposeOnTap parameter will not work
  ///
  /// Note: If `disableDefaultTargetGestures` is true then make sure to
  /// dismiss current showcase with `ShowCaseWidget.of(context).dismiss()`
  /// if you are navigating to other screen. This will be handled by default
  /// if `disableDefaultTargetGestures` is set to false.
  final bool disableDefaultTargetGestures;

  /// Defines blur value.
  /// This will blur the background while displaying showcase.
  ///
  /// If null value is provided,
  /// [ShowCaseWidget.blurValue] will be considered.
  ///
  final double? blurValue;

  /// A duration for animation which is going to played when
  /// tooltip comes first time in the view.
  ///
  /// Defaults to 300 ms.
  final Duration scaleAnimationDuration;

  /// The curve to be used for initial animation of tooltip.
  ///
  /// Defaults to Curves.easeIn
  final Curve scaleAnimationCurve;

  /// An alignment to origin of initial tooltip animation.
  ///
  /// Alignment will be pre-calculated but if pre-calculated
  /// alignment doesn't work then this parameter can be
  /// used to customise the direction of the tooltip animation.
  ///
  /// eg.
  /// ```dart
  ///     Alignment(-0.2,0.3) or Alignment.centerLeft
  /// ```
  final Alignment? scaleAnimationAlignment;

  /// Defines vertical position of tooltip respective to Target widget
  ///
  /// Defaults to adaptive into available space.
  final TooltipPosition? tooltipPosition;

  /// Provides padding around the title. Default padding is zero.
  final EdgeInsets? titlePadding;

  /// Provides padding around the description. Default padding is zero.
  final EdgeInsets? descriptionPadding;

  /// Provides text direction of tooltip title.
  final TextDirection? titleTextDirection;

  /// Provides text direction of tooltip description.
  final TextDirection? descriptionTextDirection;

  /// Provides a callback when barrier has been clicked.
  ///
  /// Note-: Even if barrier interactions are disabled, this handler
  /// will still provide a callback.
  final VoidCallback? onBarrierClick;

  /// Disables barrier interaction for a particular showCase.
  final bool disableBarrierInteraction;

  /// Defines motion range for tooltip slide animation.
  /// Which is from 0 to [toolTipSlideEndDistance].
  ///
  /// Defaults to 7.
  final double toolTipSlideEndDistance;

  /// Title widget alignment within tooltip widget
  ///
  /// Defaults to [Alignment.center]
  final AlignmentGeometry titleAlignment;

  /// Title text alignment with in tooltip widget
  ///
  /// Defaults to [TextAlign.start]
  /// To understand how text is aligned, check [TextAlign]
  final TextAlign titleTextAlign;

  /// Description widget alignment within tooltip widget
  ///
  /// Defaults to [Alignment.center]
  final AlignmentGeometry descriptionAlignment;

  /// Description text alignment with in tooltip widget
  ///
  /// Defaults to [TextAlign.start]
  /// To understand how text is aligned, check [TextAlign]
  final TextAlign descriptionTextAlign;

  /// Defines the margin from the screen edge for the tooltip.
  /// ToolTip will try to not cross this border around the screen
  ///
  /// Defaults to 14.
  final double toolTipMargin;

  /// Provides toolTip action widgets at bottom in tooltip.
  ///
  /// one can use [TooltipActionButton] class to use default action
  final List<TooltipActionButton>? tooltipActions;

  /// Provide a configuration for tooltip action widget like alignment,
  /// position, gap, etc...
  ///
  /// Default to [const TooltipActionConfig()]
  final TooltipActionConfig? tooltipActionConfig;

  /// Defines the alignment for the auto scroll function.
  ///
  /// Defaults to 0.5.
  final double scrollAlignment;

  /// While target widget is out viewport then
  /// whether enabling auto scroll so as to make the target widget visible.
  /// This is used to override the [ShowCaseWidget.enableAutoScroll] behaviour
  /// for this showcase.
  final bool? enableAutoScroll;

  /// Defines the space between target widget and tooltip.
  ///
  /// Defaults to 10.
  final double targetTooltipGap;

  @override
  State<Showcase> createState() => _ShowcaseState();
}

class _ShowcaseState extends State<Showcase> {
  ShowcaseController get _controller => ShowcaseService.instance.getController(
        key: widget.showcaseKey,
        id: _uniqueId,
        scope: _showCaseWidgetManager.name,
      );

  late ShowcaseScope _showCaseWidgetManager;

  late final int _uniqueId = widget.hashCode;

  @override
  void initState() {
    super.initState();
    _showCaseWidgetManager = ShowcaseService.instance.getScope();
    ShowcaseController.register(
      id: _uniqueId,
      key: widget.showcaseKey,
      getState: () => this,
      showcaseView: _showCaseWidgetManager.showcaseView,
    );

    // We need to update this in every showcase so we can get the latest overlay
    // state every time
    // This is helpful in scenarios like in first screen showcase is in
    // normal place and in second screen it is in some nested navigator
    // so offset and overlay position may change
    OverlayManager.instance.updateState(
      context.findRootAncestorStateOfType<OverlayState>(),
    );
  }

  @override
  void didUpdateWidget(covariant Showcase oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget == widget) return;
    _updateControllerValues();
  }

  @override
  Widget build(BuildContext context) {
    // This is to support hot reload
    _updateControllerValues();

    _controller.recalculateRootWidgetSize(
      context,
      shouldUpdateOverlay:
          _showCaseWidgetManager.showcaseView.getActiveShowcaseKey ==
              widget.showcaseKey,
    );
    return widget.child;
  }

  @override
  void dispose() {
    ShowcaseService.instance.removeController(
      key: widget.showcaseKey,
      id: _uniqueId,
      scope: _showCaseWidgetManager.name,
    );
    super.dispose();
  }

  void _updateControllerValues() {
    final manager = ShowcaseService.instance.getScope(
      scope: _showCaseWidgetManager.name,
    );
    if (manager == _showCaseWidgetManager) return;
    _showCaseWidgetManager = manager;
    ShowcaseService.instance.addController(
      controller: _controller
        ..showcaseView = _showCaseWidgetManager.showcaseView,
      key: widget.showcaseKey,
      id: _uniqueId,
      scope: _showCaseWidgetManager.name,
    );
  }
}
