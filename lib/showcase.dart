import 'package:flutter/material.dart';

class ShowCase extends StatefulWidget {
  final Widget child;

  const ShowCase({Key key, @required this.child}) : super(key: key);

  static activeView(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedShowCaseView)
            as _InheritedShowCaseView)
        .activeWidgetIds;
  }

  static startShowCase(BuildContext context, List<GlobalKey> widgetIds) {
    _ShowCaseState state = context
        .ancestorStateOfType(TypeMatcher<_ShowCaseState>()) as _ShowCaseState;

    state.startShowCase(widgetIds);
  }

  static completed(BuildContext context, GlobalKey widgetIds) {
    _ShowCaseState state = context
        .ancestorStateOfType(TypeMatcher<_ShowCaseState>()) as _ShowCaseState;

    state.completed(widgetIds);
  }

  static dismiss(BuildContext context) {
    _ShowCaseState state = context
        .ancestorStateOfType(TypeMatcher<_ShowCaseState>()) as _ShowCaseState;
    state.dismiss();
  }

  @override
  _ShowCaseState createState() => _ShowCaseState();
}

class _ShowCaseState extends State<ShowCase> {
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
      child: widget.child,
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
