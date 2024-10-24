import 'package:flutter/material.dart';

import '../../showcaseview.dart';

class TooltipActionButton {
  /// To Provide Background color to the action
  final Color? backgroundColor;

  /// To Provide borderRadius to the action
  ///
  /// Defaults to const BorderRadius.all(Radius.circular(50)),
  final BorderRadius? borderRadius;

  /// To Provide textStyle to the action text
  ///
  /// Defaults to const TextStyle(color: Colors.white,),
  final TextStyle? textStyle;

  /// To Provide padding to the action widget
  ///
  /// Defaults to const EdgeInsets.symmetric(horizontal: 15,vertical: 4,)
  final EdgeInsets? padding;

  /// To Provide a custom widget for the action in [TooltipActionButton.custom]
  final Widget? button;

  /// To Provide a leading icon for the action
  final ActionButtonIcon? leadIcon;

  /// To Provide a tail icon for the action
  final ActionButtonIcon? tailIcon;

  /// To Provide a action type
  final TooltipDefaultActionType? type;

  /// To Provide a text for action
  ///
  /// If type is provided then it will take type name
  final String? name;

  /// To Provide a onTap for action
  ///
  /// If type is provided then it will take type's OnTap
  final VoidCallback? onTap;

  /// To Provide a border for action
  final double? borderWidth;

  /// To Provide a borderColor for action
  final Color? borderColor;

  /// To show or hide action for the first tooltip
  ///
  /// defaults to true
  final bool shouldShowForFirstTooltip;

  /// To show or hide action for the hide tooltip
  ///
  /// defaults to true
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
