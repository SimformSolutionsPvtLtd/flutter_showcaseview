/*
 * Copyright (c) 2021 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
import 'package:flutter/material.dart';

import '../../showcaseview.dart';

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
  final ShowcaseView showCaseState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return config.button ??
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
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
