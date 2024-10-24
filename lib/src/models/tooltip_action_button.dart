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
  final Border? border;

  /// Hides action widgets for the showcase. Add key of particular showcase
  /// in this list.
  /// This only works for the global action widgets
  /// Defaults to []
  final List<GlobalKey> hideActionWidgetForShowcase;

  /// A configuration for a tooltip action button or Provide a custom tooltip action.
  ///
  /// This class allows you to define predefined actions like "Next,"
  /// "Previous," and "Close," or specify a custom action widget.
  ///
  /// **Required arguments:**
  ///
  /// - `type`: The type of the action button (e.g., `TooltipDefaultActionType.next`).
  ///
  /// **Optional arguments:**
  ///
  /// - `backgroundColor`: The background color of the button
  /// - `textStyle`: The text style for the button label.
  /// - `borderRadius`: The border radius of the button. Defaults to a rounded shape.
  /// - `padding`: The padding around the button content.
  /// - `leadIcon`: An optional leading icon for the button.
  /// - `tailIcon`: An optional trailing icon for the button.
  /// - `name`: The text for the button label (ignored if `type` is provided).
  /// - `onTap`: A callback function triggered when the button is tapped.
  /// - `border`: A border to draw around the button.
  /// - `hideActionWidgetForShowcase`: A list of `GlobalKey`s of showcases where this
  /// action widget should be hidden. This only works for global action widgets.
  const TooltipActionButton({
    required this.type,
    this.backgroundColor,
    this.textStyle,
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
    this.hideActionWidgetForShowcase = const [],
    this.border,
  }) : button = null;

  const TooltipActionButton.custom({
    required this.button,
    this.hideActionWidgetForShowcase = const [],
  })  : backgroundColor = null,
        borderRadius = null,
        textStyle = null,
        padding = null,
        leadIcon = null,
        tailIcon = null,
        type = null,
        name = null,
        onTap = null,
        border = null;
}
