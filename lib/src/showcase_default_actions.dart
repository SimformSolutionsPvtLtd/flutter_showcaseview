import 'package:flutter/material.dart';

import '../showcaseview.dart';

class ShowCaseDefaultActions extends StatelessWidget {
  final VoidCallback? onNext, onPrev, onStop;
  final Color? textColor;
  final BuildContext context;
  final bool next, previous, stop;

  ShowCaseDefaultActions({
    this.onNext,
    this.onPrev,
    this.onStop,
    this.textColor = Colors.white,
    required this.context,
    this.next = true,
    this.stop = true,
    this.previous = true,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Row(
          children: [
            TextButton(
              child: Text(
                'Previous',
                style: TextStyle(color: textColor),
              ),
              onPressed: onPrev ??
                  () {
                    if (ShowCaseWidget.of(this.context)!.ids != null) {
                      ShowCaseWidget.of(this.context)!.prev();
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
                    if (ShowCaseWidget.of(this.context)!.ids != null) {
                      ShowCaseWidget.of(this.context)!.completed(
                          ShowCaseWidget.of(this.context)!.ids![
                              ShowCaseWidget.of(this.context)!.activeWidgetId ??
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
                    if (ShowCaseWidget.of(this.context)!.ids != null) {
                      ShowCaseWidget.of(this.context)!.dismiss();
                    }
                  },
            ),
          ],
        );
      },
    );
  }
}
