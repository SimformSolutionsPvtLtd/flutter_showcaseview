import 'package:flutter/material.dart';

import '../showcaseview.dart';

class TooltipActionButtonWidget extends StatelessWidget {
  const TooltipActionButtonWidget({
    super.key,
    required this.config,
    required this.showCaseState,
  });

  /// This will provide the configuration for the action buttons
  final TooltipActionButton config;

  /// This is used for [TooltipActionButton] to close, next and previous
  /// showcase navigation
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
              border: config.border,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
      config.type?.onTap(showCaseState);
    }
  }
}
