import 'package:flutter/material.dart';
import 'package:showcaseview/src/utilities/_showcase_context_provider.dart';

import '../showcaseview.dart';

class ShowCaseDefaultActions extends StatelessWidget {
  final VoidCallback? onNext, onPrev, onStop;
  final Color? textColor;

  final bool next, previous, stop;

  ShowCaseDefaultActions({
    this.onNext,
    this.onPrev,
    this.onStop,
    this.textColor = Colors.white,
    this.next = true,
    this.stop = true,
    this.previous = true,
  });

  @override
  Widget build(BuildContext context) {
    final showcaseContext = ShowcaseContextProvider.of(context)?.context;

    return Row(
      children: [
        TextButton(
          child: Text(
            'Previous',
            style: TextStyle(color: textColor),
          ),
          onPressed: onPrev ??
              () {
                if (showcaseContext != null &&
                    ShowCaseWidget.of(showcaseContext)!.ids != null) {
                  ShowCaseWidget.of(showcaseContext)!.prev();
                }
              },
        ),
        TextButton(
          child: Text(
            'Next',
            style: TextStyle(color: textColor),
          ),
          onPressed: onNext ??
              () {
                if (showcaseContext != null &&
                    ShowCaseWidget.of(showcaseContext)!.ids != null) {
                  ShowCaseWidget.of(showcaseContext)!.completed(
                      ShowCaseWidget.of(showcaseContext)!.ids![
                          ShowCaseWidget.of(showcaseContext)!.activeWidgetId ??
                              0]);
                }
              },
        ),
        TextButton(
          child: Text(
            'Stop',
            style: TextStyle(color: textColor),
          ),
          onPressed: onStop ??
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
