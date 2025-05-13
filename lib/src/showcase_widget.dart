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

import '../showcaseview.dart';

typedef FloatingActionBuilderCallback = FloatingActionWidget Function(
  BuildContext context,
);

typedef OnDismissCallback = void Function(
  /// this is the key on which showcase is dismissed
  GlobalKey? dismissedAt,
);

class ShowCaseWidget extends StatefulWidget {
  @Deprecated('This will be removed in v5.0.0.')
  final WidgetBuilder builder;

  /// Triggered when all the showcases are completed.
  final VoidCallback? onFinish;

  /// Triggered when onDismiss is called
  final OnDismissCallback? onDismiss;

  /// Triggered every time on start of each showcase.
  final Function(int?, GlobalKey)? onStart;

  /// Triggered every time on completion of each showcase
  final Function(int?, GlobalKey)? onComplete;

  /// Whether all showcases will auto sequentially start
  /// having time interval of [autoPlayDelay] .
  ///
  /// Default to `false`
  final bool autoPlay;

  /// Visibility time of current showcase when [autoplay] sets to true.
  ///
  /// Default to [Duration(seconds: 3)]
  final Duration autoPlayDelay;

  /// Whether blocking user interaction while [autoPlay] is enabled.
  ///
  /// Default to `false`
  final bool enableAutoPlayLock;

  /// Whether disabling bouncing/moving animation for all tooltips
  /// while showcasing
  ///
  /// Default to `false`
  final bool disableMovingAnimation;

  /// Whether disabling initial scale animation for all the default tooltips
  /// when showcase is started and completed
  ///
  /// Default to `false`
  final bool disableScaleAnimation;

  /// Whether disabling barrier interaction
  final bool disableBarrierInteraction;

  /// Provides time duration for auto scrolling when [enableAutoScroll] is true
  final Duration scrollDuration;

  /// Default overlay blur used by showcase. if [Showcase.blurValue]
  /// is not provided.
  ///
  /// Default value is 0.
  final double blurValue;

  /// While target widget is out viewport then
  /// whether enabling auto scroll so as to make the target widget visible.
  final bool enableAutoScroll;

  /// Enable/disable showcase globally. Enabled by default.
  final bool enableShowcase;

  /// Custom static floating action widget to show a static widget anywhere
  /// on the screen for all the showcase widget
  /// Use this context to access showcaseWidget operation otherwise it will
  /// throw error.
  final FloatingActionBuilderCallback? globalFloatingActionWidget;

  /// Global action to apply on every tooltip widget
  final List<TooltipActionButton>? globalTooltipActions;

  /// Global Config for tooltip action to auto apply for all the toolTip.
  final TooltipActionConfig? globalTooltipActionConfig;

  /// Hides [globalFloatingActionWidget] for the provided showcase widgets. Add key of
  /// showcase in which [globalFloatingActionWidget] should be hidden this list.
  /// Defaults to [].
  final List<GlobalKey> hideFloatingActionWidgetForShowcase;

  /// A widget that manages multiple Showcase widgets.
  ///
  /// This widget provides a way to sequentially showcase multiple widgets
  /// with customizable options like auto-play, animation, and user interaction.
  ///
  /// **Required arguments:**
  ///
  /// - `builder`: A builder function that returns a widget containing the `Showcase` widgets to be showcased.
  ///
  /// **Optional arguments:**
  ///
  /// - `onFinish`: A callback function triggered when all showcases are completed.
  /// - `onStart`: A callback function triggered at the start of each showcase, providing the index and key of the target widget.
  /// - `onComplete`: A callback function triggered at the completion of each showcase, providing the index and key of the target widget.
  /// - `onDismiss`: A callback function triggered when showcase view is dismissed.
  /// - `autoPlay`: Whether to automatically start showcasing the next widget after a delay (defaults to `false`).
  /// - `autoPlayDelay`: The delay between each showcase during auto-play (defaults to 2 seconds).
  /// - `enableAutoPlayLock`: Whether to block user interaction while auto-play is enabled (defaults to `false`).
  /// - `blurValue`: The amount of background blur applied during the showcase (defaults to 0).
  /// - `scrollDuration`: The duration of the scrolling animation when auto-scrolling to a target widget (defaults to 300 milliseconds).
  /// - `disableMovingAnimation`: Disables the animation when moving the tooltip for all showcases (defaults to `false`).
  /// - `disableScaleAnimation`: Disables the initial scale animation for all tooltips (defaults to `false`).
  /// - `enableAutoScroll`: Enables automatic scrolling to bring the target widget into view (defaults to `false`).
  /// - `disableBarrierInteraction`: Disables user interaction with the area outside the showcase overlay (defaults to `false`).
  /// - `enableShowcase`: Enables or disables the showcase functionality globally (defaults to `true`).
  /// - `globalTooltipActions`: A list of custom actions to be added to all tooltips.
  /// - `globalTooltipActionConfig`: Configuration options for the global tooltip actions.
  /// - `globalFloatingActionWidget`: Custom static floating action widget to show a static widget anywhere for all the showcase widgets.
  /// - `hideFloatingActionWidgetForShowcase`: Hides a [globalFloatingActionWidget] for the provided showcase keys.
  @Deprecated(
    'This will be removed in v5.0.0. '
    'Please use `ShowcaseView.register()` instead',
  )
  const ShowCaseWidget({
    required this.builder,
    this.onFinish,
    this.onStart,
    this.onComplete,
    this.onDismiss,
    this.autoPlay = false,
    this.autoPlayDelay = const Duration(milliseconds: 2000),
    this.enableAutoPlayLock = false,
    this.blurValue = 0,
    this.scrollDuration = const Duration(milliseconds: 300),
    this.disableMovingAnimation = false,
    this.disableScaleAnimation = false,
    this.enableAutoScroll = false,
    this.disableBarrierInteraction = false,
    this.enableShowcase = true,
    this.globalTooltipActionConfig,
    this.globalTooltipActions,
    this.globalFloatingActionWidget,
    this.hideFloatingActionWidgetForShowcase = const [],
  });

  @Deprecated(
    'This will be removed in v5.0.0. please use '
    '`ShowcaseView.get().getCurrentActiveShowcaseKey` instead',
  )
  static GlobalKey? activeTargetWidget(BuildContext context) => context
      .findAncestorStateOfType<ShowCaseWidgetState>()
      ?.getCurrentActiveShowcaseKey;

  @Deprecated(
    'This will be removed in v5.0.0. please use '
    '`ShowcaseView.get()` instead',
  )
  static ShowCaseWidgetState of(BuildContext context) {
    final state = context.findAncestorStateOfType<ShowCaseWidgetState>();
    if (state != null) {
      return state;
    } else {
      throw Exception('Please provide ShowCaseView context');
    }
  }

  @override
  ShowCaseWidgetState createState() => ShowCaseWidgetState();
}

class ShowCaseWidgetState extends State<ShowCaseWidget> {
  late ShowcaseView _showcaseView;

  @override
  void initState() {
    super.initState();
    _showcaseView = ShowcaseView.register(
      scope: widget.hashCode.toString(),
      onFinish: widget.onFinish,
      onStart: widget.onStart,
      onComplete: widget.onComplete,
      onDismiss: widget.onDismiss,
      autoPlay: widget.autoPlay,
      autoPlayDelay: widget.autoPlayDelay,
      enableAutoPlayLock: widget.enableAutoPlayLock,
      blurValue: widget.blurValue,
      scrollDuration: widget.scrollDuration,
      disableMovingAnimation: widget.disableMovingAnimation,
      disableScaleAnimation: widget.disableScaleAnimation,
      enableAutoScroll: widget.enableAutoScroll,
      disableBarrierInteraction: widget.disableBarrierInteraction,
      enableShowcase: widget.enableShowcase,
      globalTooltipActionConfig: widget.globalTooltipActionConfig,
      globalTooltipActions: widget.globalTooltipActions,
      globalFloatingActionWidget: widget.globalFloatingActionWidget,
      hideFloatingActionWidgetForShowcase:
          widget.hideFloatingActionWidgetForShowcase,
    );
  }

  @override
  void didUpdateWidget(covariant ShowCaseWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _showcaseView
      ..autoPlay = widget.autoPlay
      ..autoPlayDelay = widget.autoPlayDelay
      ..enableAutoPlayLock = widget.enableAutoPlayLock
      ..blurValue = widget.blurValue
      ..scrollDuration = widget.scrollDuration
      ..disableMovingAnimation = widget.disableMovingAnimation
      ..disableScaleAnimation = widget.disableScaleAnimation
      ..enableAutoScroll = widget.enableAutoScroll
      ..disableBarrierInteraction = widget.disableBarrierInteraction
      ..enableShowcase = widget.enableShowcase
      ..globalTooltipActionConfig = widget.globalTooltipActionConfig
      ..globalTooltipActions = widget.globalTooltipActions;
  }

  @override
  Widget build(BuildContext context) => Builder(
        //ignore: deprecated_member_use_from_same_package
        builder: widget.builder,
      );

  @override
  void dispose() {
    _showcaseView.unregister();
    super.dispose();
  }

  /// Starts Showcase view from the beginning of specified list of widget ids.
  /// If this function is used when showcase has been disabled then it will
  /// throw an exception.
  ///
  /// [delay] is optional and it will be used to delay the start of showcase
  /// which is useful when animation may take some time to complete.
  ///
  /// Refer this issue https://github.com/SimformSolutionsPvtLtd/flutter_showcaseview/issues/378
  @Deprecated(
    'This will be removed in v5.0.0. please use '
    '`ShowcaseView.get().startShowCase` instead',
  )
  void startShowCase(
    List<GlobalKey> widgetIds, {
    Duration delay = Duration.zero,
  }) {
    _showcaseView.startShowCase(widgetIds, delay: delay);
  }

  /// Completes showcase of given key and starts next one
  /// otherwise will finish the entire showcase view
  @Deprecated(
    'This will be removed in v5.0.0. please use '
    '`ShowcaseView.get().completed` instead',
  )
  void completed(GlobalKey? key) => _showcaseView.completed(key);

  /// Completes current active showcase and starts next one
  /// otherwise will finish the entire showcase view
  ///
  /// if [force] is true then it will ignore the [enableAutoPlayLock] and
  /// move to next showcase. This is default behaviour for
  /// [TooltipDefaultActionType.next]
  @Deprecated(
    'This will be removed in v5.0.0. please use '
    '`ShowcaseView.get().next` instead',
  )
  void next({bool force = false}) {
    _showcaseView.next(force: force);
  }

  /// Completes current active showcase and starts previous one
  /// otherwise will finish the entire showcase view
  @Deprecated(
    'This will be removed in v5.0.0. please use '
    '`ShowcaseView.get().previous` instead',
  )
  void previous() {
    _showcaseView.previous();
  }

  /// Dismiss entire showcase view
  @Deprecated(
    'This will be removed in v5.0.0. please use '
    '`ShowcaseView.get().dismiss` instead',
  )
  void dismiss() {
    _showcaseView.dismiss();
  }

  /// Disables the [globalFloatingActionWidget] for the provided keys.
  @Deprecated(
    'This will be removed in v5.0.0. please use '
    '`ShowcaseView.get().hideFloatingActionWidgetForKeys` instead',
  )
  void hideFloatingActionWidgetForKeys(List<GlobalKey> updatedList) {
    _showcaseView.hideFloatingActionWidgetForKeys(updatedList);
  }

  // Forward property accessors to ShowcaseManager
  @Deprecated(
    'This will be removed in v5.0.0. please use '
    '`ShowcaseView.get().autoPlay` instead',
  )
  bool get autoPlay => _showcaseView.autoPlay;

  @Deprecated(
    'This will be removed in v5.0.0. please use '
    '`ShowcaseView.get().disableMovingAnimation` instead',
  )
  bool get disableMovingAnimation => _showcaseView.disableMovingAnimation;

  @Deprecated(
    'This will be removed in v5.0.0. please use '
    '`ShowcaseView.get().disableScaleAnimation` instead',
  )
  bool get disableScaleAnimation => _showcaseView.disableScaleAnimation;

  @Deprecated(
    'This will be removed in v5.0.0. please use '
    '`ShowcaseView.get().autoPlayDelay` instead',
  )
  Duration get autoPlayDelay => _showcaseView.autoPlayDelay;

  @Deprecated(
    'This will be removed in v5.0.0. please use '
    '`ShowcaseView.get().enableAutoPlayLock` instead',
  )
  bool get enableAutoPlayLock => _showcaseView.enableAutoPlayLock;

  @Deprecated(
    'This will be removed in v5.0.0. please use '
    '`ShowcaseView.get().enableAutoScroll` instead',
  )
  bool get enableAutoScroll => _showcaseView.enableAutoScroll;

  @Deprecated(
    'This will be removed in v5.0.0. please use '
    '`ShowcaseView.get().disableBarrierInteraction` instead',
  )
  bool get disableBarrierInteraction => _showcaseView.disableBarrierInteraction;

  @Deprecated(
    'This will be removed in v5.0.0. please use '
    '`ShowcaseView.get().enableShowcase` instead',
  )
  bool get enableShowcase => _showcaseView.enableShowcase;

  @Deprecated(
    'This will be removed in v5.0.0. please use '
    '`ShowcaseView.get().isShowCaseCompleted` instead',
  )
  bool get isShowCaseCompleted => _showcaseView.isShowCaseCompleted;

  @Deprecated(
    'This will be removed in v5.0.0. please use '
    '`ShowcaseView.get().scrollDuration` instead',
  )
  Duration get scrollDuration => _showcaseView.scrollDuration;

  @Deprecated(
    'This will be removed in v5.0.0. please use '
    '`ShowcaseView.get().blurValue` instead',
  )
  double get blurValue => _showcaseView.blurValue;

  @Deprecated(
    'This will be removed in v5.0.0. please use '
    '`ShowcaseView.get().getCurrentActiveShowcaseKey` instead',
  )
  GlobalKey? get getCurrentActiveShowcaseKey =>
      _showcaseView.getCurrentActiveShowcaseKey;

  @Deprecated(
    'This will be removed in v5.0.0. please use '
    '`ShowcaseView.get().isShowcaseRunning` instead',
  )
  bool get isShowcaseRunning => _showcaseView.isShowcaseRunning;

  @Deprecated(
    'This will be removed in v5.0.0. please use '
    '`ShowcaseView.get().hiddenFloatingActionKeys` instead',
  )
  List<GlobalKey> get hiddenFloatingActionKeys =>
      _showcaseView.hiddenFloatingActionKeys;
}
