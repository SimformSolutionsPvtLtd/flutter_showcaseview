import 'package:flutter/material.dart';

import 'showcase_widget.dart';
import 'toottip_action_button.dart';

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
    bool isLastTip = activeWidgetId == (ids!.length - 1);
    Color disabledIconColor = color?.withOpacity(0.3) ?? Colors.black26;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (ids.isNotEmpty && activeWidgetId != null) ...[
          ToolTipActionButton(
            action: (isFirstTip)
                ? null
                : () {
                    showCaseWidgetState.previous();
                  },
            padding: padding,
            icon: Icons.keyboard_arrow_left,
            iconSize: iconSize,
            color: (isFirstTip) ? disabledIconColor : color,
          ),
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
          ToolTipActionButton(
            action: (isLastTip)
                ? null
                : () {
                    showCaseWidgetState.next();
                  },
            padding: padding,
            icon: Icons.keyboard_arrow_right,
            iconSize: iconSize,
            color: (isLastTip) ? disabledIconColor : color,
          )
        ],
      ],
    );
  }
}
