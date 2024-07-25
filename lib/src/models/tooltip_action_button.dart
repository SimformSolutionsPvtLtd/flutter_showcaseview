import 'package:flutter/material.dart';

import '../../showcaseview.dart';

class TooltipActionButton {
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final Widget? button;
  final ActionButtonIcon? leadIcon;
  final ActionButtonIcon? tailIcon;
  final TooltipDefaultActionType? type;
  final String? name;
  final VoidCallback? onTap;
  final double? borderWidth;
  final Color? borderColor;
  final bool shouldShowForFirstTooltip;
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
