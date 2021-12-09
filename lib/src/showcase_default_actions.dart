import 'package:flutter/material.dart';

import '../showcaseview.dart';
import 'utilities/_showcase_context_provider.dart';

class ShowCaseDefaultActions extends StatelessWidget {
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;

  final ActionButtonConfig next;
  final ActionButtonConfig previous;
  final ActionButtonConfig stop;

  ShowCaseDefaultActions({
    this.next = const ActionButtonConfig(),
    this.previous = const ActionButtonConfig(),
    this.stop = const ActionButtonConfig(),
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
  });

  @override
  Widget build(BuildContext context) {
    final showcaseContext = ShowcaseContextProvider.of(context)?.context;

    return Row(
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: mainAxisAlignment,
      verticalDirection: verticalDirection,
      crossAxisAlignment: crossAxisAlignment,
      textBaseline: textBaseline,
      textDirection: textDirection,
      children: [
        if (previous.visible)
          TextButton(
            child: Text(
              'Previous',
              style: TextStyle(color: previous.textColor),
            ),
            onPressed: previous.callback ??
                () {
                  if (showcaseContext != null &&
                      ShowCaseWidget.of(showcaseContext)!.ids != null) {
                    ShowCaseWidget.of(showcaseContext)!.prev();
                  }
                },
          ),
        if (next.visible)
          TextButton(
            child: Text(
              'Next',
              style: TextStyle(color: next.textColor),
            ),
            onPressed: next.callback ??
                () {
                  if (showcaseContext != null &&
                      ShowCaseWidget.of(showcaseContext)!.ids != null) {
                    ShowCaseWidget.of(showcaseContext)!.completed(
                        ShowCaseWidget.of(showcaseContext)!.ids![
                            ShowCaseWidget.of(showcaseContext)!
                                    .activeWidgetId ??
                                0]);
                  }
                },
          ),
        if (stop.visible)
          TextButton(
            child: Text(
              'Stop',
              style: TextStyle(color: stop.textColor),
            ),
            onPressed: stop.callback ??
                () {
                  if (showcaseContext != null &&
                      ShowCaseWidget.of(showcaseContext)!.ids != null) {
                    ShowCaseWidget.of(showcaseContext)!.dismiss();
                  }
                },
          ),
      ],
    );
  }
}

class ActionButtonConfig {
  /// Color of button text.
  final Color textColor;

  /// Callback on button tap.
  ///
  /// Note: Default callback will be overridden by this one.
  final VoidCallback? callback;

  /// Defines visibility of button.
  final bool visible;

  const ActionButtonConfig({
    this.textColor = Colors.white,
    this.callback,
    this.visible = true,
  });
}
