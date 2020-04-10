import 'package:flutter/material.dart';

class ShowCaseWidget extends StatefulWidget {
  final Widget child;
  final bool autoPlay;
  final Duration autoPlayDelay;
  final bool autoPlayLockEnable;

  const ShowCaseWidget({
    Key key,
    @required this.child,
    this.autoPlay = false,
    this.autoPlayDelay = const Duration(milliseconds: 2000),
    this.autoPlayLockEnable = false,
  }) : super(key: key);

  static activeTargetWidget(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedShowCaseView)
    as _InheritedShowCaseView)
        .activeWidgetIds;
  }

  static startShowCase(BuildContext context, List<GlobalKey> widgetIds) {
    _ShowCaseWidgetState state =
    context.ancestorStateOfType(TypeMatcher<_ShowCaseWidgetState>())
    as _ShowCaseWidgetState;

    state.startShowCase(widgetIds);
  }

  static completed(BuildContext context, GlobalKey widgetIds) {
    _ShowCaseWidgetState state =
    context.ancestorStateOfType(TypeMatcher<_ShowCaseWidgetState>())
    as _ShowCaseWidgetState;

    state.completed(widgetIds);
  }

  static dismiss(BuildContext context) {
    _ShowCaseWidgetState state =
    context.ancestorStateOfType(TypeMatcher<_ShowCaseWidgetState>())
    as _ShowCaseWidgetState;
    state.dismiss();
  }

  static autoPlayStatus(BuildContext context) {
    _ShowCaseWidgetState state = context.ancestorStateOfType(TypeMatcher<_ShowCaseWidgetState>())
    as _ShowCaseWidgetState;
    return state.autoPlay;
  }

  static autoPlayDuration(BuildContext context) {
    _ShowCaseWidgetState state = context.ancestorStateOfType(TypeMatcher<_ShowCaseWidgetState>())
    as _ShowCaseWidgetState;
    return state.autoPlayDelay;
  }

  static autoPlayLock(BuildContext context) {
    _ShowCaseWidgetState state = context.ancestorStateOfType(TypeMatcher<_ShowCaseWidgetState>())
    as _ShowCaseWidgetState;
    return state.autoPlayLockEnable;
  }

  @override
  _ShowCaseWidgetState createState() => _ShowCaseWidgetState();
}

class _ShowCaseWidgetState extends State<ShowCaseWidget> {
  List<GlobalKey> ids;
  int activeWidgetId;
  bool autoPlay;
  Duration autoPlayDelay;
  bool autoPlayLockEnable;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.autoPlayDelay = widget.autoPlayDelay;
    this.autoPlay = widget.autoPlay;
    this.autoPlayLockEnable = widget.autoPlayLockEnable;
  }
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
