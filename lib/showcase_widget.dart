/*
 * Copyright © 2020, Simform Solutions
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import 'package:flutter/material.dart';

class ShowCaseWidget extends StatefulWidget {
  final Builder builder;
  final VoidCallback onFinish;

  const ShowCaseWidget({@required this.builder, this.onFinish});

  static activeTargetWidget(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedShowCaseView>()
        .activeWidgetIds;
  }

  static ShowCaseWidgetState of(BuildContext context) {
    ShowCaseWidgetState state =
    context.findAncestorStateOfType<ShowCaseWidgetState>();
    if (state != null) {
      return context.findAncestorStateOfType<ShowCaseWidgetState>();
    } else {
      throw Exception('Please provide ShowCaseView context');
    }
  }

  @override
  ShowCaseWidgetState createState() => ShowCaseWidgetState();
}

class ShowCaseWidgetState extends State<ShowCaseWidget> {
  List<GlobalKey> ids;
  int activeWidgetId;

  void startShowCase(List<GlobalKey> widgetIds) {
    setState(() {
      this.ids = widgetIds;
      activeWidgetId = 0;
    });
  }

  void completed(GlobalKey id) {
    if (ids != null && ids[activeWidgetId] == id) {
      setState(() {
        ++activeWidgetId;

        if (activeWidgetId >= ids.length) {
          _cleanupAfterSteps();
          if (widget.onFinish != null) {
            widget.onFinish();
          }
        }
      });
    }
  }

  void dismiss() {
    setState(() {
      _cleanupAfterSteps();
    });
  }

  void _cleanupAfterSteps() {
    ids = null;
    activeWidgetId = null;
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedShowCaseView(
      child: widget.builder,
      activeWidgetIds: ids?.elementAt(activeWidgetId),
    );
  }
}

class _InheritedShowCaseView extends InheritedWidget {
  final GlobalKey activeWidgetIds;

  _InheritedShowCaseView({
    @required this.activeWidgetIds,
    @required child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(_InheritedShowCaseView oldWidget) =>
      oldWidget.activeWidgetIds != activeWidgetIds;
}
