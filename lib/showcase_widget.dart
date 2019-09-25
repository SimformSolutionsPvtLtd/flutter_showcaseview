import 'package:flutter/material.dart';

class ShowCaseWidget extends StatefulWidget {
  final Builder builder;
  final VoidCallback onFinish;

  const ShowCaseWidget({@required this.builder, this.onFinish});

  static activeTargetWidget(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedShowCaseView)
            as _InheritedShowCaseView)
        .activeWidgetIds;
  }

  static ShowCaseWidgetState of(BuildContext context) {
    ShowCaseWidgetState state =
        context.ancestorStateOfType(const TypeMatcher<ShowCaseWidgetState>());
    if (state != null) {
      return context
          .ancestorStateOfType(const TypeMatcher<ShowCaseWidgetState>());
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
