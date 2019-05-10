import 'package:flutter/material.dart';

class ShowCase extends StatefulWidget {
  final Widget child;

  const ShowCase({Key key, @required this.child}) : super(key: key);

  static activeView(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedShowCaseView)
            as _InheritedShowCaseView)
        .activeWidgetIds;
  }

  static startShowCase(BuildContext context, List<String> widgetIds) {
    _ShowCaseState state = context
        .ancestorStateOfType(TypeMatcher<_ShowCaseState>()) as _ShowCaseState;

    state.startShowCase(widgetIds);
  }

  static completed(BuildContext context, String widgetIds) {
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
  List<String> ids;

  void startShowCase(List<String> widgetIds) {
    setState(() {
      this.ids = widgetIds;
    });
  }

  void completed(String widgetIds) {}

  void dismiss() {}

  @override
  Widget build(BuildContext context) {
    return _InheritedShowCaseView(
      child: widget.child,
      activeWidgetIds: ids?.elementAt(0),
    );
  }
}

class _InheritedShowCaseView extends InheritedWidget {
  final String activeWidgetIds;

  _InheritedShowCaseView({
    @required this.activeWidgetIds,
    @required child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(_InheritedShowCaseView oldWidget) =>
      oldWidget.activeWidgetIds != activeWidgetIds;
}
