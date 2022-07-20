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

class ShowCaseWidget extends StatefulWidget {
  final Builder builder;
  final VoidCallback? onFinish;
  final Function(int?, GlobalKey)? onStart;
  final Function(int?, GlobalKey)? onComplete;
  final bool autoPlay;
  final Duration autoPlayDelay;
  final bool autoPlayLockEnable;
  final bool disableAnimation;
  final Duration scrollDuration;
  final bool disableBarrierInteraction;

  /// Default overlay blur used by showcase. if [Showcase.blurValue]
  /// is not provided.
  ///
  /// Default value is 0.
  final double blurValue;

  const ShowCaseWidget({
    required this.builder,
    this.onFinish,
    this.onStart,
    this.onComplete,
    this.autoPlay = false,
    this.disableBarrierInteraction = false,
    this.autoPlayDelay = const Duration(milliseconds: 2000),
    this.autoPlayLockEnable = false,
    this.blurValue = 0,
    this.scrollDuration = const Duration(milliseconds: 300),
    this.disableAnimation = false,
  });

  static GlobalKey? activeTargetWidget(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_InheritedShowCaseView>()?.activeWidgetIds;
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
  late bool autoPlay;
  late bool disableAnimation;
  late Duration autoPlayDelay;
  late bool autoPlayLockEnable;
  late bool disableBarrierInteraction;

  /// Returns value of  [ShowCaseWidget.blurValue]
  double get blurValue => widget.blurValue;

  @override
  void initState() {
    super.initState();
    autoPlayDelay = widget.autoPlayDelay;
    autoPlay = widget.autoPlay;
    disableAnimation = widget.disableAnimation;
    autoPlayLockEnable = widget.autoPlayLockEnable;
    disableBarrierInteraction = widget.disableBarrierInteraction;
  }

  void startShowCase(List<GlobalKey> widgetIds) {
    if (mounted) {
      setState(() {
        ids = widgetIds;
        activeWidgetId = 0;
        _onStart();
      });
    }
  }

  void completed(GlobalKey? id) {
    if (ids != null && ids![activeWidgetId!] == id && mounted) {
      setState(() {
        _onComplete();
        activeWidgetId = activeWidgetId! + 1;
        _onStart();

        if (activeWidgetId! >= ids!.length) {
          _cleanupAfterSteps();
          if (widget.onFinish != null) {
            widget.onFinish!();
          }
        }
      });
    }
  }

  void next() {
    if (ids != null && mounted) {
      setState(() {
        _onComplete();
        activeWidgetId = activeWidgetId! + 1;
        _onStart();

        if (activeWidgetId! >= ids!.length) {
          _cleanupAfterSteps();
          if (widget.onFinish != null) {
            widget.onFinish!();
          }
        }
      });
    }
  }

  void previous() {
    if (ids != null && ((activeWidgetId ?? 0) - 1) >= 0 && mounted) {
      setState(() {
        _onComplete();
        activeWidgetId = activeWidgetId! - 1;
        _onStart();
        if (activeWidgetId! >= ids!.length) {
          _cleanupAfterSteps();
          if (widget.onFinish != null) {
            widget.onFinish!();
          }
        }
      });
    }
  }

  void dismiss() {
    if (mounted) {
      setState(_cleanupAfterSteps);
    }
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

  @override
  Widget build(BuildContext context) {
    return _InheritedShowCaseView(
      activeWidgetIds: ids?.elementAt(activeWidgetId!),
      child: widget.builder,
    );
  }
}

class _InheritedShowCaseView extends InheritedWidget {
  final GlobalKey? activeWidgetIds;

  const _InheritedShowCaseView({
    required this.activeWidgetIds,
    required Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(_InheritedShowCaseView oldWidget) => oldWidget.activeWidgetIds != activeWidgetIds;
}
