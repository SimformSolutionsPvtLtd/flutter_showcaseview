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

import '../models/tooltip_action_config.dart';

class ActionWidget extends StatelessWidget {
  /// A widget that displays action buttons in a tooltip.
  ///
  /// This widget is responsible for rendering and aligning action buttons
  /// within the tooltip. It works in conjunction with [TooltipActionConfig] to
  /// determine how these action buttons should be laid out.
  ///
  /// The widget can be positioned in two ways:
  /// - Inside the tooltip content (when [TooltipActionConfig.position] is set
  /// to [TooltipActionPosition.inside]).
  /// - Outside the tooltip content (when [TooltipActionConfig.position] is set
  /// to [TooltipActionPosition.outside] or when a custom container is used).
  ///
  /// The layout of action buttons can be customized using:
  /// - [alignment] - Controls how buttons are spaced horizontally.
  /// - [crossAxisAlignment] - Controls how buttons are aligned vertically.
  /// - [outsidePadding] - Adds padding around the buttons when placed inside
  /// the tooltip.
  const ActionWidget({
    required this.children,
    required this.tooltipActionConfig,
    this.outsidePadding = EdgeInsets.zero,
    super.key,
  });

  final TooltipActionConfig tooltipActionConfig;
  final List<Widget> children;
  final EdgeInsets outsidePadding;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: outsidePadding,
        child: tooltipActionConfig.position.isInsideHorizontal
            ? Column(
                mainAxisSize: tooltipActionConfig.mainAxisSize,
                mainAxisAlignment: tooltipActionConfig.alignment,
                crossAxisAlignment: tooltipActionConfig.crossAxisAlignment,
                textBaseline: tooltipActionConfig.textBaseline,
                children: children,
              )
            : Row(
                mainAxisSize: tooltipActionConfig.mainAxisSize,
                mainAxisAlignment: tooltipActionConfig.alignment,
                crossAxisAlignment: tooltipActionConfig.crossAxisAlignment,
                textBaseline: tooltipActionConfig.textBaseline,
                children: children,
              ),
      ),
    );
  }
}
