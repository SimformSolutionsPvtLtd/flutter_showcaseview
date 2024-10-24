import 'package:flutter/material.dart';

import '../../showcaseview.dart';

class TooltipActionButton {
  /// To Provide Background color to the action in [TooltipActionButton.withDefault]
  final Color? backgroundColor;

  /// To Provide borderRadius to the action in [TooltipActionButton.withDefault]
  final BorderRadius? borderRadius;

  /// To Provide textStyle to the action text in [TooltipActionButton.withDefault]
  final TextStyle? textStyle;

  /// To Provide padding to the action widget
  final EdgeInsets? padding;

  /// To Provide a custom widget for the action in [TooltipActionButton.custom]
  final Widget? button;

  /// To Provide a leading icon for the action in [TooltipActionButton.withDefault]
  final ActionButtonIcon? leadIcon;

  /// To Provide a tail icon for the action in [TooltipActionButton.withDefault]
  final ActionButtonIcon? tailIcon;

  /// To Provide a action type in [TooltipActionButton.withDefault]
  final TooltipDefaultActionType? type;

  /// To Provide a text for action in [TooltipActionButton.withDefault]
  final String? name;

  /// To Provide a onTap for action in [TooltipActionButton.withDefault]
  final VoidCallback? onTap;

  /// To Provide a border for action in [TooltipActionButton.withDefault]
  final double? borderWidth;

  /// To Provide a borderColor for action in [TooltipActionButton.withDefault]
  final Color? borderColor;

  /// To show or hide action for the first tooltip defaults to [true]
  final bool shouldShowForFirstTooltip;

  /// To show or hide action for the hide tooltip defaults to [true]
  final bool shouldShowForLastTooltip;

  TooltipActionButton.withDefault({
    required this.type,
    this.backgroundColor,
    this.textStyle = const TextStyle(
      color: Colors.white,
    ),
    this.borderRadius = const BorderRadius.all(
      Radius.circular(50),
    ),
    this.padding = const EdgeInsets.symmetric(
      horizontal: 15,
      vertical: 4,
    ),
    this.leadIcon,
    this.tailIcon,
    this.name,
    this.onTap,
    this.borderColor,
    this.borderWidth,
    this.shouldShowForFirstTooltip = true,
    this.shouldShowForLastTooltip = true,
  }) : button = null;

  TooltipActionButton.custom({
    required this.button,
    this.shouldShowForFirstTooltip = true,
    this.shouldShowForLastTooltip = true,
  })  : backgroundColor = null,
        borderRadius = null,
        textStyle = null,
        padding = null,
        leadIcon = null,
        tailIcon = null,
        type = null,
        name = null,
        onTap = null,
        borderColor = null,
        borderWidth = null;
}
