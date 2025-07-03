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

import '../models/tooltip_action_button.dart';
import '../showcase/showcase_view.dart';

class TooltipActionButtonWidget extends StatelessWidget {
  /// A widget that renders action buttons within showcase tooltips.
  ///
  /// This widget is responsible for building interactive buttons that appear
  /// in showcase tooltips, such as "Next," "Previous," or "Skip" buttons. It
  /// renders either a custom button provided in the config or builds a
  /// standard button with optional leading/trailing icons based on the
  /// provided configuration.
  ///
  /// It supports both local tooltip actions (specific to a single showcase)
  /// and global tooltip actions (applied to all showcases in a sequence).
  const TooltipActionButtonWidget({
    required this.config,
    required this.showCaseState,
    super.key,
  });

  /// This will provide the configuration for the action buttons.
  final TooltipActionButton config;

  /// This is used for close, next and previous showcase navigation.
  final ShowcaseView showCaseState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return config.button ??
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _handleOnTap,
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
                  if (config.leadIcon case final lead?)
                    Padding(
                      padding: lead.padding ?? const EdgeInsets.only(right: 5),
                      child: lead.icon,
                    ),
                  Text(
                    config.name ?? config.type?.actionName ?? '',
                    style: config.textStyle,
                  ),
                  if (config.tailIcon case final tail?)
                    Padding(
                      padding: tail.padding ?? const EdgeInsets.only(left: 5),
                      child: tail.icon,
                    ),
                ],
              ),
            ),
          ),
        );
  }

  void _handleOnTap() {
    if (config.onTap != null) {
      config.onTap?.call();
    } else {
      config.type?.onTap(showCaseState);
    }
  }
}
