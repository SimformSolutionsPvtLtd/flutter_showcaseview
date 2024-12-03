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
  BuildContext,
);

class ShowCaseWidget extends StatefulWidget {
  final WidgetBuilder builder;

  /// Triggered when all the showcases are completed.
  final VoidCallback? onFinish;

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
  const ShowCaseWidget({
    required this.builder,
    this.onFinish,
    this.onStart,
    this.onComplete,
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

  static GlobalKey? activeTargetWidget(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedShowCaseView>()
        ?.activeWidgetIds;
  }

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
  List<GlobalKey>? ids;
  int? activeWidgetId;
  RenderBox? rootRenderObject;
  Size? rootWidgetSize;
  final anchoredOverlayKey = UniqueKey();

  late final TooltipActionConfig? globalTooltipActionConfig;

  late final List<TooltipActionButton>? globalTooltipActions;

  /// These properties are only here so that it can be accessed by
  /// [Showcase]
  bool get autoPlay => widget.autoPlay;

  bool get disableMovingAnimation => widget.disableMovingAnimation;

  bool get disableScaleAnimation => widget.disableScaleAnimation;

  Duration get autoPlayDelay => widget.autoPlayDelay;

  bool get enableAutoPlayLock => widget.enableAutoPlayLock;

  bool get enableAutoScroll => widget.enableAutoScroll;

  bool get disableBarrierInteraction => widget.disableBarrierInteraction;

  bool get enableShowcase => widget.enableShowcase;

  bool get isShowCaseCompleted => ids == null && activeWidgetId == null;

  List<GlobalKey> get hiddenFloatingActionKeys =>
      _hideFloatingWidgetKeys.keys.toList();

  /// This Stores keys of showcase for which we will hide the
  /// [globalFloatingActionWidget].
  late final _hideFloatingWidgetKeys = {
    for (final item in widget.hideFloatingActionWidgetForShowcase) item: true
  };

  /// Returns value of [ShowCaseWidget.blurValue]
  double get blurValue => widget.blurValue;

  /// Returns current active showcase key
  GlobalKey? get getCurrentActiveShowcaseKey {
    if (ids == null || activeWidgetId == null) return null;

    if (activeWidgetId! < ids!.length && activeWidgetId! >= 0) {
      return ids![activeWidgetId!];
    } else {
      return null;
    }
  }

  /// Return a [widget.globalFloatingActionWidget] if not need to hide this for
  /// current showcase.
  FloatingActionBuilderCallback? get globalFloatingActionWidget =>
      _hideFloatingWidgetKeys[getCurrentActiveShowcaseKey] ?? false
          ? null
          : widget.globalFloatingActionWidget;

  @override
  void initState() {
    super.initState();
    globalTooltipActions = widget.globalTooltipActions;
    globalTooltipActionConfig = widget.globalTooltipActionConfig;
    initRootWidget();
  }

  void initRootWidget() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final rootWidget = context.findAncestorStateOfType<State<WidgetsApp>>();
      rootRenderObject = rootWidget?.context.findRenderObject() as RenderBox?;
      rootWidgetSize = rootWidget == null
          ? MediaQuery.of(context).size
          : rootRenderObject?.size;
    });
  }

  /// Starts Showcase view from the beginning of specified list of widget ids.
  /// If this function is used when showcase has been disabled then it will
  /// throw an exception.
  void startShowCase(List<GlobalKey> widgetIds) {
    if (!enableShowcase) {
      throw Exception(
        "You are trying to start Showcase while it has been disabled with "
        "`enableShowcase` parameter to false from ShowCaseWidget",
      );
    }
    if (!mounted) return;
    setState(() {
      ids = widgetIds;
      activeWidgetId = 0;
      _onStart();
    });
  }

  /// Completes showcase of given key and starts next one
  /// otherwise will finish the entire showcase view
  void completed(GlobalKey? key) {
    if (ids != null && ids![activeWidgetId!] == key && mounted) {
      setState(() {
        _onComplete();
        activeWidgetId = activeWidgetId! + 1;
        _onStart();

        if (activeWidgetId! >= ids!.length) {
          _cleanupAfterSteps();
          widget.onFinish?.call();
        }
      });
    }
  }

  /// Completes current active showcase and starts next one
  /// otherwise will finish the entire showcase view
  void next() {
    if (ids != null && mounted) {
      setState(() {
        _onComplete();
        activeWidgetId = activeWidgetId! + 1;
        _onStart();

        if (activeWidgetId! >= ids!.length) {
          _cleanupAfterSteps();
          widget.onFinish?.call();
        }
      });
    }
  }

  /// Completes current active showcase and starts previous one
  /// otherwise will finish the entire showcase view
  void previous() {
    if (ids != null && ((activeWidgetId ?? 0) - 1) >= 0 && mounted) {
      setState(() {
        _onComplete();
        activeWidgetId = activeWidgetId! - 1;
        _onStart();
        if (activeWidgetId! >= ids!.length) {
          _cleanupAfterSteps();
          widget.onFinish?.call();
        }
      });
    }
  }

  /// Dismiss entire showcase view
  void dismiss() {
    if (mounted) setState(_cleanupAfterSteps);
  }

  void _onStart() {
    if (activeWidgetId! < ids!.length) {
      widget.onStart?.call(activeWidgetId, ids![activeWidgetId!]);
    }
  }

  void _onComplete() {
    widget.onComplete?.call(activeWidgetId, ids![activeWidgetId!]);
  }

  void _cleanupAfterSteps() {
    ids = null;
    activeWidgetId = null;
  }

  /// Disables the [globalFloatingActionWidget] for the provided keys.
  void hideFloatingActionWidgetForKeys(
    List<GlobalKey> updatedList,
  ) {
    _hideFloatingWidgetKeys
      ..clear()
      ..addAll({for (final item in updatedList) item: true});
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedShowCaseView(
      activeWidgetIds: ids?.elementAt(activeWidgetId!),
      child: Builder(
        builder: widget.builder,
      ),
    );
  }
}

class _InheritedShowCaseView extends InheritedWidget {
  final GlobalKey? activeWidgetIds;

  const _InheritedShowCaseView({
    required this.activeWidgetIds,
    required super.child,
  });

  @override
  bool updateShouldNotify(_InheritedShowCaseView oldWidget) =>
      oldWidget.activeWidgetIds != activeWidgetIds;
}
