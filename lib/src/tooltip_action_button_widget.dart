import 'package:flutter/material.dart';

import '../showcaseview.dart';

class TooltipActionButtonWidget extends StatelessWidget {
  const TooltipActionButtonWidget({
    super.key,
    required this.config,
    required this.showCaseState,
  });

  final TooltipActionButton config;
  final ShowCaseWidgetState showCaseState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return config.button ??
        GestureDetector(
          onTap: handleOnTap,
          child: Container(
            padding: config.padding,
            decoration: BoxDecoration(
              color: config.backgroundColor ?? theme.primaryColor,
              borderRadius: config.borderRadius,
              border: Border.all(
                color: config.borderColor ??
                    config.backgroundColor ??
                    theme.primaryColor,
                width: config.borderWidth ?? 0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (config.leadIcon != null)
                  Padding(
                    padding: config.leadIcon?.padding ??
                        const EdgeInsets.only(right: 5),
                    child: config.leadIcon?.icon,
                  ),
                Text(
                  config.name ?? config.type?.actionName ?? '',
                  style: config.textStyle,
                ),
                if (config.tailIcon != null)
                  Padding(
                    padding: config.tailIcon?.padding ??
                        const EdgeInsets.only(left: 5),
                    child: config.tailIcon?.icon,
                  ),
              ],
            ),
          ),
        );
  }

  void handleOnTap() {
    if (config.onTap != null) {
      config.onTap?.call();
    } else {
      switch (config.type) {
        case TooltipDefaultActionType.next:
          showCaseState.next();
          break;
        case TooltipDefaultActionType.previous:
          showCaseState.previous();
          break;
        case TooltipDefaultActionType.skip:
          showCaseState.dismiss();
          break;
        default:
          throw ArgumentError('Invalid tooltip default action type');
      }
    }
  }
}
