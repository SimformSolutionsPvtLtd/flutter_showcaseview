import 'package:flutter/material.dart';

import 'showcase_widget.dart';
import 'tooltip_action_button.dart';

/// Default Tooltip action Widget Nav
/// Shows tooltip navigation and index / count elements if the conditions are
/// indicated.
class DefaultToolTipAction extends StatelessWidget {
  const DefaultToolTipAction({
    super.key,
    this.color = Colors.black,
    required this.showCaseWidgetState,
    this.padding = EdgeInsets.zero,
    this.textStyle,
    this.iconSize,
    this.back,
    this.forward,
    this.buttonColor,
    this.onBackPress,
    this.onForwardPress,
  });

  final Color color;
  final ShowCaseWidgetState showCaseWidgetState;
  final EdgeInsets padding;
  final TextStyle? textStyle;
  final double? iconSize;
  final Widget? back;
  final Widget? forward;
  final Color? buttonColor;
  final VoidCallback? onBackPress;
  final VoidCallback? onForwardPress;

  @override
  Widget build(BuildContext context) {
    var ids = showCaseWidgetState.ids;
    var activeWidgetId = showCaseWidgetState.activeWidgetId;
    bool isFirstTip = activeWidgetId == 0;
    bool isLastTip = activeWidgetId == (ids!.length - 1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (ids.isNotEmpty && activeWidgetId != null) ...[
          ToolTipActionButton(
            action: isFirstTip
                ? null
                : () {
                    showCaseWidgetState.previous();
                    onBackPress?.call();
                  },
            padding: padding,
            widget: back ??
                Icon(
                  Icons.keyboard_arrow_left,
                  color: buttonColor ?? color,
                ),
            opacity: isFirstTip ? 0.3 : 1,
          ),
          const SizedBox(
            width: 4.0,
          ),
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
          const SizedBox(
            width: 4.0,
          ),
          ToolTipActionButton(
            action: isLastTip
                ? null
                : () {
                    showCaseWidgetState.next();
                    onForwardPress?.call();
                  },
            padding: padding,
            widget: forward ??
                Icon(
                  Icons.keyboard_arrow_right,
                  color: buttonColor ?? color,
                ),
            opacity: isLastTip ? 0.3 : 1,
          )
        ],
      ],
    );
  }
}
