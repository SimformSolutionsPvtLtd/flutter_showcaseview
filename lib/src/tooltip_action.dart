import 'package:flutter/material.dart';

import 'showcase_widget.dart';

/// Default Tooltip action Widget Nav
/// Shows tooltip navigation and index / count elements if the conditions are
/// indicated.
class DefaultToolTipActionWidget extends StatelessWidget {
  const DefaultToolTipActionWidget({
    Key? key,
    required this.color,
    required this.showCaseWidgetState,
    this.padding = const EdgeInsets.only(top: 5),
    this.textStyle,
    this.iconSize,
  }) : super(key: key);

  final Color? color;
  final ShowCaseWidgetState showCaseWidgetState;
  final EdgeInsets padding;
  final TextStyle? textStyle;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    var ids = showCaseWidgetState.ids;
    var activeWidgetId = showCaseWidgetState.activeWidgetId;
    bool isFirstTip = activeWidgetId == 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: (isFirstTip)
              ? null
              : () {
                  showCaseWidgetState.previous();
                },
          child: Padding(
            padding: padding,
            child: Icon(
              Icons.keyboard_arrow_left,
              size: iconSize,
              color: (isFirstTip)
                  ? color?.withOpacity(0.3) ?? Colors.black26
                  : color,
            ),
          ),
        ),
        if (ids != null && activeWidgetId != null) ...[
          const SizedBox(width: 4.0),
          Padding(
            padding: padding,
            child: Text(
              "${activeWidgetId + 1} / ${ids.length}",
              style: textStyle ??
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: color,
                      ),
            ),
          ),
          const SizedBox(width: 4.0),
        ],
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            showCaseWidgetState.next();
          },
          child: Padding(
            padding: padding,
            child: Icon(
              Icons.keyboard_arrow_right,
              color: color,
              size: iconSize,
            ),
          ),
        ),
      ],
    );
  }
}
