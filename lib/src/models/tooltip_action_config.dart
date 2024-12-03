import 'package:flutter/material.dart';

import '../../showcaseview.dart';

class TooltipActionConfig {
  /// Configuration options for tooltip action buttons.
  ///
  /// This class allows you to configure the overall appearance and layout of
  /// action buttons within a tooltip widget.
  const TooltipActionConfig({
    this.alignment = MainAxisAlignment.spaceBetween,
    this.actionGap = 5,
    this.position = TooltipActionPosition.inside,
    this.gapBetweenContentAndAction = 10,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.textBaseline,
  }) : assert(
          !identical(crossAxisAlignment, CrossAxisAlignment.stretch),
          'Can not use stretch as height is unbounded',
        );

  /// Defines tooltip action widget position.
  /// It can be inside the tooltip widget or outside.
  ///
  /// Default to [TooltipActionPosition.inside]
  final TooltipActionPosition position;

  /// Defines the alignment of actions buttons of tooltip action widget
  ///
  /// Default to [MainAxisAlignment.spaceBetween]
  final MainAxisAlignment alignment;

  /// Defines the gap between the actions buttons of tooltip action widget
  ///
  /// Default to 5.0
  final double actionGap;

  /// Defines vertically gap between tooltip content and actions.
  ///
  /// Default to 10.0
  final double gapBetweenContentAndAction;

  /// Defines running direction alignment for the Action widgets.
  ///
  /// Default to [crossAxisAlignment.start]
  final CrossAxisAlignment crossAxisAlignment;

  /// If aligning items according to their baseline, which baseline to use.
  ///
  /// This must be set if using baseline alignment. There is no default because there is no
  /// way for the framework to know the correct baseline _a priori_.
  final TextBaseline? textBaseline;
}
