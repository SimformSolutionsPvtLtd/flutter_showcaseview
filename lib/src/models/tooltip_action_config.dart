import 'package:flutter/material.dart';

import '../../showcaseview.dart';

class TooltipActionConfig {
  const TooltipActionConfig({
    this.alignment = TooltipActionAlignment.left,
    this.actionGap = 5,
    this.padding = EdgeInsets.zero,
    this.position = TooltipActionPosition.inside,
    this.gapBetweenContentAndAction = 10,
  });

  /// Defines tooltip action widget position.
  /// It can be inside the tooltip widget or outside.
  ///
  /// Default to [TooltipActionPosition.inside]
  final TooltipActionPosition position;

  /// Defines the alignment of actions buttons of tooltip action widget
  ///
  /// Default to [TooltipActionAlignment.left]
  final TooltipActionAlignment alignment;

  /// Defines the gap between the actions buttons of tooltip action widget
  ///
  /// Default to 5.0
  final double actionGap;

  /// Defines the padding in the tooltip action widget
  ///
  /// Default to [EdgeInsets.zero]
  final EdgeInsets padding;

  /// Defines vertically gap between tooltip content and actions.
  ///
  /// Default to 10.0
  final double gapBetweenContentAndAction;
}
