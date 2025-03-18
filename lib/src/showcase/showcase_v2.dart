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

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../enum.dart';
import '../get_position.dart';
import '../models/linked_showcase_data.dart';
import '../models/tooltip_action_button.dart';
import '../models/tooltip_action_config.dart';
import '../showcase_widget.dart';
import '../tooltip/tooltip.dart';
import '../tooltip_action_button_widget.dart';
import '../widget/floating_action_widget.dart';
import 'showcase_controller.dart';

class Showcase extends StatefulWidget {
  /// A key that is unique across the entire app.
  ///
  /// This Key will be used to control state of individual showcase and also
  /// used in [ShowCaseWidgetState.startShowCase] to define position of current
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
  /// Note: If [targetBorderRadius] is specified, this parameter will be ignored.
  ///
  /// Default value is:
  /// ```dart
  /// RoundedRectangleBorder(
  ///   borderRadius: BorderRadius.all(Radius.circular(8)),
  /// ),
  /// ```
  final ShapeBorder targetShapeBorder;

  /// Radius of rectangle box while target widget is being showcased.
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

  /// Whether the default tooltip will have arrow to point out the target widget.
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
  /// Detected when a pointer has remained in contact with the screen at the same location for a long period of time.
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

  /// Defines the margin for the tooltip.
  /// Which is from 0 to [toolTipSlideEndDistance].
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

  /// This keys will be used to show multiple showcase widget.
  /// Note: When child showcase are visible their [onBarrierClick] click will
  /// not work as there will be only parent barrier.
  ///
  /// Defaults to <GlobalKey>[].
  final List<GlobalKey> linkedShowcaseKeys;

  /// Highlights a specific widget on the screen with an informative tooltip.
  ///
  /// This widget helps you showcase specific parts of your UI by drawing an
  /// overlay around it and displaying a description. You can customize the
  /// appearance and behavior of the showcase and tooltip for a seamless user
  /// experience.
  ///
  /// **Required arguments:**
  ///
  /// - `key`: A unique key for this Showcase widget.
  /// - `description`: A description of the widget being showcased.
  /// - `child`: The widget you want to highlight.
  ///
  /// **Optional arguments:**
  ///
  /// **Tooltip:**
  ///   - `title`: An optional title for the tooltip.
  ///   - `titleAlignment`: Alignment of the title text within the tooltip (defaults to start).
  ///   - `descriptionAlignment`: Alignment of the description text within the tooltip (defaults to start).
  ///   - `titleTextStyle`: Style properties for the title text.
  ///   - `descTextStyle`: Style properties for the description text.
  ///   - `tooltipBackgroundColor`: Background color of the tooltip (defaults to white).
  ///   - `textColor`: Color of the text in the tooltip (defaults to black).
  ///   - `tooltipPadding`: Padding around the content inside the tooltip.
  ///   - `onToolTipClick`: A callback function called when the user clicks the tooltip.
  ///   - `tooltipBorderRadius`: The border radius of the tooltip (defaults to 8dp).
  ///
  /// **Highlight:**
  ///   - `targetShapeBorder`: The border to draw around the showcased widget (defaults to a rounded rectangle).
  ///   - `targetPadding`: Padding around the showcased widget (defaults to none).
  ///   - `showArrow`: Whether to show an arrow pointing to the showcased widget (defaults to true).
  ///
  /// **Animations:**
  ///   - `movingAnimationDuration`: Duration of the animation when moving the tooltip (defaults to 2 seconds).
  ///   - `disableMovingAnimation`: Disables the animation when moving the tooltip.
  ///   - `disableScaleAnimation`: Disables the animation when scaling the tooltip.
  ///   - `scaleAnimationDuration`: Duration of the animation when scaling the tooltip (defaults to 300 milliseconds).
  ///   - `scaleAnimationCurve`: The curve used for the scaling animation (defaults to ease-in).
  ///   - `scaleAnimationAlignment`: The alignment point for the scaling animation.
  ///
  /// **Interactions:**
  ///   - `onTargetClick`: A callback function called when the user clicks the showcased widget.
  ///   - `disposeOnTap`: Whether to dispose of the showcase after a tap on the showcased widget (requires `onTargetClick`).
  ///   - `onTargetLongPress`: A callback function called when the user long-presses the showcased widget.
  ///   - `onTargetDoubleTap`: A callback function called when the user double-taps the showcased widget.
  ///   - `disableDefaultTargetGestures`: Disables default gestures on the target widget (panning, zooming).
  ///   - `onBarrierClick`: A callback function called when the user clicks outside the showcase overlay.
  ///   - `disableBarrierInteraction`: Disables user interaction with the area outside the showcase overlay.
  ///
  /// **Advanced:**
  ///   - `container`: A custom widget to use as the tooltip instead of the default one.
  ///   - `overlayColor`: Color of the showcase overlay (defaults to black with 75% opacity).
  ///   - `overlayOpacity`: Opacity of the showcase overlay (0.0 to 1.0).
  ///   - `scrollLoadingWidget`: A widget to display while content is loading (for infinite scrolling scenarios).
  ///   - `blurValue`: The amount of background blur applied during the showcase.
  ///   - `tooltipPosition`: The position of the tooltip relative to the showcased widget.
  ///   - `toolTipSlideEndDistance`: The distance the tooltip slides in from the edge of the screen (defaults to 7dp).
  ///   - `toolTipMargin`: The margin around the tooltip (defaults to 14dp).
  ///   - `tooltipActions`: A list of custom actions (widgets) to display within the tooltip.
  ///   - `tooltipActionConfig`: Configuration options for custom tooltip actions.
  ///   - `scrollAlignment`: Defines the alignment for the auto scroll function.
  ///   - `enableAutoScroll`:This is used to override the [ShowCaseWidget.enableAutoScroll] behaviour for this showcase.
  ///   - `linkedShowcaseKeys`: This is used to show multiple showcase at the same time provide linked showcase keys in this list
  ///
  /// **Assertions:**
  ///
  /// - `overlayOpacity` must be between 0.0 and 1.0.
  /// - `onTargetClick` and `disposeOnTap` must be used together (one cannot exist without the other).
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
    this.scrollLoadingWidget = const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.white),
    ),
    this.showArrow = true,
    this.onTargetClick,
    this.disposeOnTap,
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
    this.linkedShowcaseKeys = const <GlobalKey>[],
  })  : height = null,
        width = null,
        container = null,
        showcaseKey = key,
        assert(overlayOpacity >= 0.0 && overlayOpacity <= 1.0,
            "overlay opacity must be between 0 and 1."),
        assert(onTargetClick == null || disposeOnTap != null,
            "disposeOnTap is required if you're using onTargetClick"),
        assert(disposeOnTap == null || onTargetClick != null,
            "onTargetClick is required if you're using disposeOnTap"),
        assert(onBarrierClick == null || disableBarrierInteraction == false,
            "can't use onBarrierClick & disableBarrierInteraction property at same time");

  /// Creates a Showcase widget with a custom tooltip widget.
  ///
  /// This constructor allows you to provide a completely custom widget
  /// for the tooltip instead of using the default one with title and
  /// description.  This gives you more flexibility in designing the
  /// appearance and behavior of the tooltip.
  ///
  /// **Required arguments:**
  ///
  /// - `key`: A unique key for this Showcase widget.
  /// - `height`: The height of the custom tooltip widget.
  /// - `width`: The width of the custom tooltip widget.
  /// - `container`: The custom widget to use as the tooltip.
  /// - `child`: The widget you want to highlight.
  ///
  /// **Optional arguments:**
  ///
  /// **Highlight:**
  /// - `targetShapeBorder`: The border to draw around the showcased widget (defaults to a rounded rectangle).
  /// - `targetBorderRadius`: The border radius of the showcased widget.
  /// - `overlayColor`: Color of the showcase overlay (defaults to black with 75% opacity).
  /// - `overlayOpacity`: Opacity of the showcase overlay (0.0 to 1.0).
  /// - `scrollLoadingWidget`: A widget to display while content is loading (for infinite scrolling scenarios).
  /// - `onTargetClick`: A callback function called when the user clicks the showcased widget.
  /// - `disposeOnTap`: Whether to dispose of the showcase after a tap on the showcased widget (requires `onTargetClick`).
  /// - `movingAnimationDuration`: Duration of the animation when moving the tooltip (defaults to 2 seconds).
  /// - `disableMovingAnimation`: Disables the animation when moving the tooltip.
  /// - `targetPadding`: Padding around the showcased widget (defaults to none).
  /// - `blurValue`: The amount of background blur applied during the showcase.
  /// - `onTargetLongPress`: A callback function called when the user long-presses the showcased widget.
  /// - `onTargetDoubleTap`: A callback function called when the user double-taps the showcased widget.
  /// - `disableDefaultTargetGestures`: Disables default gestures on the target widget (panning, zooming).
  /// - `tooltipPosition`: The position of the tooltip relative to the showcased widget.
  /// - `onBarrierClick`: A callback function called when the user clicks outside the showcase overlay.
  /// - `disableBarrierInteraction`: Disables user interaction with the area outside the showcase overlay.
  ///
  /// **Advanced:**
  /// - `toolTipSlideEndDistance`: The distance the tooltip slides in from the edge of the screen (defaults to 7dp).
  /// - `tooltipActions`: A list of custom actions (widgets) to display within the tooltip.
  /// - `tooltipActionConfig`: Configuration options for custom tooltip actions.
  /// - `floatingActionWidget`: Custom static floating action widget to show a static widget anywhere
  /// - `linkedShowcaseKeys`: This is used to show multiple showcase at the same time provide linked showcase keys in this list
  ///
  /// **Differences from default constructor:**
  ///
  /// - This constructor doesn't require `title` or `description` arguments.
  /// - By default, the tooltip won't have an arrow pointing to the target widget (`showArrow` is set to `false`).
  /// - Default click behavior is disabled (`onToolTipClick` is set to `null`).
  /// - Default animation settings are slightly different (e.g., `scaleAnimationCurve` is `Curves.decelerate`).
  ///
  /// **Assertions:**
  ///   - `overlayOpacity` must be between 0.0 and 1.0.
  ///   - `onBarrierClick` cannot be used with `disableBarrierInteraction`.
  const Showcase.withWidget({
    required GlobalKey key,
    required this.height,
    required this.width,
    required this.container,
    required this.child,
    this.floatingActionWidget,
    this.targetShapeBorder = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(8),
      ),
    ),
    this.overlayColor = Colors.black45,
    this.targetBorderRadius,
    this.overlayOpacity = 0.75,
    this.scrollLoadingWidget = const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.white)),
    this.onTargetClick,
    this.disposeOnTap,
    this.movingAnimationDuration = const Duration(milliseconds: 2000),
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
    this.linkedShowcaseKeys = const <GlobalKey>[],
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
        toolTipMargin = 14,
        showcaseKey = key,
        assert(overlayOpacity >= 0.0 && overlayOpacity <= 1.0,
            "overlay opacity must be between 0 and 1."),
        assert(onBarrierClick == null || disableBarrierInteraction == false,
            "can't use onBarrierClick & disableBarrierInteraction property at same time");

  @override
  State<Showcase> createState() => _ShowcaseState();
}

class _ShowcaseState extends State<Showcase> {
  // bool showShowCase = false;
  // bool isScrollRunning = false;
  bool isTooltipDismissed = false;
  bool enableShowcase = true;
  // Timer? timer;
  GetPosition? position;

  late ShowcaseController showcaseController;

  late final showCaseWidgetState = ShowCaseWidget.of(context);
  FloatingActionWidget? _globalFloatingActionWidget;

  /// This variable will be true if some other showcase is linked with
  /// this showcase and starts this widget showcase
  // bool _isLinkedShowCaseStarted = false;

  bool get _isCircle => widget.targetShapeBorder is CircleBorder;

  BorderRadius? get _targetBorderRadius => widget.targetBorderRadius;

  EdgeInsets get _targetPadding => widget.targetPadding;

  // bool get isSecondaryShowcase =>
  //     showCaseWidgetState.firstShowcaseStarted?.showcaseId !=
  //     showcaseController?.showcaseId;

  @override
  void initState() {
    super.initState();
    initRootWidget();
    final connectedShowcase =
        showCaseWidgetState.showcaseController[widget.showcaseKey];
    showcaseController = ShowcaseController(
      showcaseId: connectedShowcase?.length ?? 0,
      showcaseKey: widget.showcaseKey,
      showcaseConfig: widget,
    )..startShowcase = startShowcase;

    if (connectedShowcase != null) {
      showCaseWidgetState.showcaseController[widget.showcaseKey]
          ?.add(showcaseController);
    } else {
      showCaseWidgetState.showcaseController[widget.showcaseKey] = [
        showcaseController
      ];
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    recalculateRootWidgetSize();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        _updateControllerData(context);
      },
    );
  }

  @override
  void didUpdateWidget(covariant Showcase oldWidget) {
    super.didUpdateWidget(oldWidget);
    recalculateRootWidgetSize();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        _updateControllerData(context);
      },
    );
  }

  void startShowcase() {
    enableShowcase = showCaseWidgetState.enableShowcase;

    recalculateRootWidgetSize();

    if (enableShowcase) {
      _globalFloatingActionWidget = showCaseWidgetState
          .globalFloatingActionWidget(widget.showcaseKey)
          ?.call(context);
      final size = MediaQuery.of(context).size;
      position ??= GetPosition(
        rootRenderObject: showcaseController.rootRenderObject,
        context: context,
        padding: widget.targetPadding,
        screenWidth: showcaseController.rootWidgetSize?.width ?? size.width,
        screenHeight: showcaseController.rootWidgetSize?.height ?? size.height,
      );
      showOverlay();
    }
  }

  // void closeShowcase() {
  //   // setState(() {
  //   // showShowCase = false;
  //   timer?.cancel();
  //   timer = null;
  //   // });
  // }

  /// show overlay if there is any target widget
  void showOverlay() {
    // final activeStep = showCaseWidgetState.getCurrentActiveShowcaseKey;
    // final linkedShowcases = showCaseWidgetState.showcaseController[activeStep];
    // if this showcase is linked to current active showcase then we will make
    // _isLinkedShowCaseStarted true

    // } else {
    //   _isLinkedShowCaseStarted = false;
    // }
    // print(showcaseController?.showcaseId);
    // setState(() {
    //   showShowCase = activeStep == widget.showcaseKey;
    // });

    if (
        // showShowCase &&
        (widget.enableAutoScroll ?? showCaseWidgetState.enableAutoScroll)) {
      _scrollIntoView();
    }
    // else if (timer?.isActive ?? false) {
    //   timer?.cancel();
    //   timer = null;
    // }
  }

  void _scrollIntoView() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (!mounted) return;
      setState(() => showcaseController.isScrollRunning = true);
      await Scrollable.ensureVisible(
        context,
        duration: showCaseWidgetState.widget.scrollDuration,
        alignment: widget.scrollAlignment,
      );
      if (!mounted) return;
      setState(() => showcaseController.isScrollRunning = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // return AnchoredOverlay(
    //   key: showCaseWidgetState.anchoredOverlayKey,
    //   rootRenderObject: rootRenderObject,
    //   overlayBuilder: (overlayContext, rectBound, offset) {
    //     showcaseController?.position = position!;
    //     showcaseController?.linkedShowcaseDataModel = LinkedShowcaseDataModel(
    //       rect: rectBound,
    //       radius: _targetBorderRadius,
    //       overlayPadding: _targetPadding,
    //       isCircle: _isCircle,
    //     );
    //
    //      buildOverlayOnTarget(
    //       position!.getOffSet(),
    //       position!.getRect().size,
    //       position!.getRect(),
    //       size,
    //       [],
    //     );
    //   },
    //   showOverlay: false,
    //   child: widget.child,
    // );
    // }
    return widget.child;
  }

  @override
  void dispose() {
    // timer?.cancel();
    // timer = null;
    showCaseWidgetState.showcaseController[widget.showcaseKey]
        ?.remove(showcaseController);
    super.dispose();
  }

  void initRootWidget() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showcaseController.rootWidgetSize = showCaseWidgetState.rootWidgetSize;
      showcaseController.rootRenderObject =
          showCaseWidgetState.rootRenderObject;
    });
  }

  void recalculateRootWidgetSize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final rootWidget =
          context.findRootAncestorStateOfType<State<ShowCaseWidget>>();
      showcaseController.rootRenderObject =
          rootWidget?.context.findRenderObject() as RenderBox?;
      showcaseController.rootWidgetSize = rootWidget == null
          ? MediaQuery.of(context).size
          : showcaseController.rootRenderObject?.size;
    });
  }

  Future<void> _nextIfAny() async {
    if (showCaseWidgetState.isShowCaseCompleted) return;

    // if (timer != null && timer!.isActive) {
    //   if (showCaseWidgetState.enableAutoPlayLock) {
    //     return;
    //   }
    //   timer!.cancel();
    // } else if (timer != null && !timer!.isActive) {
    //   timer = null;
    // }
    // await _connectedReverseAnimatedToolTip();
    showCaseWidgetState.completed(widget.showcaseKey);
  }

  Future<void> _getOnTargetTap() async {
    if (widget.disposeOnTap == true) {
      // await _connectedReverseAnimatedToolTip();
      showCaseWidgetState.dismiss();
      widget.onTargetClick!();
    } else {
      (widget.onTargetClick ?? _nextIfAny).call();
    }
  }

  Future<void> _getOnTooltipTap() async {
    if (widget.disposeOnTap == true) {
      // await _connectedReverseAnimatedToolTip();
      showCaseWidgetState.dismiss();
    }
    widget.onToolTipClick?.call();
  }

  /// Reverse animates the provided tooltip or
  /// the custom container widget.
  // Future<void> _reverseAnimateTooltip() async {
  //   if (!mounted) return;
  //   setState(() => isTooltipDismissed = true);
  //   await Future<dynamic>.delayed(widget.scaleAnimationDuration);
  //   isTooltipDismissed = false;
  // }

  /// This function is used to maintain all showcase reverse animation. When
  /// [_isLinkedShowCaseStarted] is true it will call parent's reverse animation
  /// function which will handle all child animation.
  // Future<void> _connectedReverseAnimatedToolTip() async {
  //   if (false) {
  //     final primaryShowcaseController =
  //         showCaseWidgetState.firstShowcaseStarted;
  //
  //     if (primaryShowcaseController != null) {
  //       await primaryShowcaseController.connectedReverseAnimation();
  //     }
  //   } else {
  //     var futureList = <Future>[_reverseAnimateTooltip()];
  //     for (final controller
  //         in showCaseWidgetState.showcaseController[widget.showcaseKey] ??
  //             <ShowcaseController>[]) {
  //       if (controller == showcaseController) continue;
  //       futureList.add(controller.reverseAnimation());
  //     }
  //     await Future.wait(futureList);
  //   }
  // }

  void buildOverlayOnTarget(
    Offset offset,
    Size size,
    Rect rectBound,
    Size screenSize,
  ) {
    var blur = 0.0;

    blur = widget.blurValue ?? showCaseWidgetState.blurValue;

    blur = kIsWeb && blur < 0 ? 0 : blur;

    // if (!showShowCase) return const Offstage();

    // if (showCaseWidgetState.getCurrentActiveShowcaseKey == widget.showcaseKey &&
    //     showCaseWidgetState.firstShowcaseStarted == null) {
    //   showCaseWidgetState.firstShowcaseStarted = showcaseController;
    // }
    // if (showCaseWidgetState.autoPlay) {
    //   timer ??= Timer(
    //     Duration(seconds: showCaseWidgetState.autoPlayDelay.inSeconds),
    //     _nextIfAny,
    //   );
    // }

    showcaseController
      ..position = position!
      ..blur = blur
      ..getToolTipWidget = [
        if (showcaseController.isScrollRunning)
          Center(child: widget.scrollLoadingWidget),
        if (!showcaseController.isScrollRunning) ...[
          _TargetWidget(
            offset: rectBound.topLeft,
            size: size,
            onTap: _getOnTargetTap,
            radius: widget.targetBorderRadius,
            onDoubleTap: widget.onTargetDoubleTap,
            onLongPress: widget.onTargetLongPress,
            shapeBorder: widget.targetShapeBorder,
            disableDefaultChildGestures: widget.disableDefaultTargetGestures,
            targetPadding: widget.targetPadding,
          ),
          ToolTipWidget(
            key: ValueKey(showcaseController.hashCode),
            position: position,
            offset: offset,
            screenSize: screenSize,
            title: widget.title,
            titleTextAlign: widget.titleTextAlign,
            description: widget.description,
            descriptionTextAlign: widget.descriptionTextAlign,
            titleAlignment: widget.titleAlignment,
            descriptionAlignment: widget.descriptionAlignment,
            titleTextStyle: widget.titleTextStyle,
            descTextStyle: widget.descTextStyle,
            container: widget.container,
            floatingActionWidget:
                widget.floatingActionWidget ?? _globalFloatingActionWidget,
            tooltipBackgroundColor: widget.tooltipBackgroundColor,
            textColor: widget.textColor,
            showArrow: widget.showArrow,
            contentHeight: widget.height,
            contentWidth: widget.width,
            onTooltipTap:
                widget.disposeOnTap == true || widget.onToolTipClick != null
                    ? _getOnTooltipTap
                    : null,
            tooltipPadding: widget.tooltipPadding,
            disableMovingAnimation: widget.disableMovingAnimation ??
                showCaseWidgetState.disableMovingAnimation,
            disableScaleAnimation: widget.container != null
                ? true
                : widget.disableScaleAnimation ??
                    showCaseWidgetState.disableScaleAnimation,
            movingAnimationDuration: widget.movingAnimationDuration,
            tooltipBorderRadius: widget.tooltipBorderRadius,
            scaleAnimationDuration: widget.scaleAnimationDuration,
            scaleAnimationCurve: widget.scaleAnimationCurve,
            scaleAnimationAlignment: widget.scaleAnimationAlignment,
            isTooltipDismissed: isTooltipDismissed,
            tooltipPosition: widget.tooltipPosition,
            titlePadding: widget.titlePadding,
            descriptionPadding: widget.descriptionPadding,
            titleTextDirection: widget.titleTextDirection,
            descriptionTextDirection: widget.descriptionTextDirection,
            toolTipSlideEndDistance: widget.toolTipSlideEndDistance,
            toolTipMargin: widget.toolTipMargin,
            tooltipActionConfig: _getTooltipActionConfig(),
            tooltipActions: _getTooltipActions(),
            targetPadding: widget.targetPadding,
            showcaseController: showcaseController,
          ),
          if (_getFloatingActionWidget != null) _getFloatingActionWidget!,
        ],
      ];
  }

  Widget? get _getFloatingActionWidget =>
      widget.floatingActionWidget ?? _globalFloatingActionWidget;

  List<Widget> _getTooltipActions() {
    final actionData = (widget.tooltipActions?.isNotEmpty ?? false)
        ? widget.tooltipActions!
        : showCaseWidgetState.globalTooltipActions ?? [];

    final actionWidgets = <Widget>[];
    for (final action in actionData) {
      /// This checks that if current widget is being showcased and there is
      /// no local action has been provided and global action are needed to hide
      /// then it will hide that action for current widget
      if (
          // showShowCase &&

          action.hideActionWidgetForShowcase.contains(widget.showcaseKey) &&
              (widget.tooltipActions?.isEmpty ?? true)) {
        continue;
      }
      actionWidgets.add(
        Padding(
          padding: EdgeInsetsDirectional.only(
            end: action != actionData.last
                ? _getTooltipActionConfig().actionGap
                : 0,
          ),
          child: TooltipActionButtonWidget(
            config: action,
            // We have to pass showcaseState from here because
            // [TooltipActionButtonWidget] is not direct child of showcaseWidget
            // so it won't be able to get the state by using it's context
            showCaseState: showCaseWidgetState,
          ),
        ),
      );
    }
    return actionWidgets;
  }

  TooltipActionConfig _getTooltipActionConfig() {
    return widget.tooltipActionConfig ??
        showCaseWidgetState.globalTooltipActionConfig ??
        const TooltipActionConfig();
  }

  void _updateControllerData(BuildContext context) {
    final size =
        showcaseController.rootWidgetSize ?? MediaQuery.of(context).size;
    position = GetPosition(
      rootRenderObject: showcaseController.rootRenderObject,
      context: context,
      padding: widget.targetPadding,
      screenWidth: size.width,
      screenHeight: size.height,
    );
    showcaseController.position = position!;
    showcaseController.linkedShowcaseDataModel = LinkedShowcaseDataModel(
      rect:
          showcaseController.isScrollRunning ? Rect.zero : position!.getRect(),
      radius: _targetBorderRadius,
      overlayPadding:
          showcaseController.isScrollRunning ? EdgeInsets.zero : _targetPadding,
      isCircle: _isCircle,
    );

    buildOverlayOnTarget(
      position!.getOffSet(),
      position!.getRect().size,
      position!.getRect(),
      size,
    );
  }
}

class _TargetWidget extends StatelessWidget {
  final Offset offset;
  final Size size;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final ShapeBorder shapeBorder;
  final BorderRadius? radius;
  final bool disableDefaultChildGestures;
  final EdgeInsets targetPadding;

  const _TargetWidget({
    required this.offset,
    required this.size,
    required this.shapeBorder,
    required this.targetPadding,
    this.onTap,
    this.radius,
    this.onDoubleTap,
    this.onLongPress,
    this.disableDefaultChildGestures = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: offset.dy - targetPadding.top,
      left: offset.dx - targetPadding.left,
      child: disableDefaultChildGestures
          ? IgnorePointer(
              child: targetWidgetContent(),
            )
          : MouseRegion(
              cursor: SystemMouseCursors.click,
              child: targetWidgetContent(),
            ),
    );
  }

  Widget targetWidgetContent() {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        height: size.height,
        width: size.width.abs(),
        margin: targetPadding,
        decoration: ShapeDecoration(
          shape: radius != null
              ? RoundedRectangleBorder(borderRadius: radius!)
              : shapeBorder,
        ),
      ),
    );
  }
}
