import 'package:flutter/material.dart';

import '../showcaseview.dart';

class ShowCaseDefaultActions extends StatelessWidget {
  final VoidCallback? onNext, onPrev, onStop;
  final Color? textColor;
  final BuildContext parentContext;

  ShowCaseDefaultActions({
    this.onNext,
    this.onPrev,
    this.onStop,
    this.textColor = Colors.white,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context){
        return Row(
          children: [
            TextButton(
              child: Text(
                'Previous',
                style: TextStyle(color: textColor),
              ),
              onPressed: onPrev ?? (){
                if (ShowCaseWidget.of(parentContext)!.ids != null) {
                  ShowCaseWidget.of(parentContext)!.prev(
                      ShowCaseWidget.of(parentContext)!.ids![
                      ShowCaseWidget.of(parentContext)!.activeWidgetId ??
                          0]);
                }
              },
            ),
            TextButton(
              child: Text('Next', style: TextStyle(color: textColor),),
              onPressed: onNext ?? (){
                if (ShowCaseWidget.of(parentContext)!.ids != null) {
                  ShowCaseWidget.of(parentContext)!.completed(
                      ShowCaseWidget.of(parentContext)!.ids![
                      ShowCaseWidget.of(parentContext)!.activeWidgetId ??
                          0]);
                }
              },
            ),
            TextButton(
              child: Text('Stop', style: TextStyle(color: textColor),),
              onPressed: onStop ?? (){
                if (ShowCaseWidget.of(parentContext)!.ids != null) {
                  ShowCaseWidget.of(parentContext)!.dismiss();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
