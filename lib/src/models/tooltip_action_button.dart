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

class TooltipActionButton {
  /// A class that defines interactive action buttons within showcase tooltips.
  ///
  /// Provides a way to add interactive buttons to tooltips in the showcase
  /// view. These buttons can perform standard navigation actions also
  /// supports custom actions through callback functions and fully custom
  /// button widgets.
  ///
  /// There are two ways to create tooltip action buttons:
  /// 1. Using the default constructor for standard buttons with predefined
  /// styles and standard action types (next, previous, skip).
  /// 2. Using the [TooltipActionButton.custom] constructor for fully custom
  /// button widgets.
  ///
  /// Tooltip action buttons can be used in two contexts:
  /// - As local actions specific to a single showcase tooltip by providing
  /// them in [Showcase.tooltipActions].
  /// - As global actions that appear in all showcase tooltips by providing
  /// them in [ShowcaseView.globalTooltipActions].
  ///
  /// The appearance and position of these buttons are controlled by the
  /// [TooltipActionConfig] class, which can define whether the buttons appear
  /// inside or outside the tooltip container and how they are aligned.
  const TooltipActionButton({
    required this.type,
    this.borderRadius = const BorderRadius.all(Radius.circular(50)),
    this.padding = const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
    this.hideActionWidgetForShowcase = const [],
    this.backgroundColor,
    this.textStyle,
    this.leadIcon,
    this.tailIcon,
    this.name,
    this.onTap,
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

  /// Background color for the action button.
  ///
  /// If not provided, theme's primary color will be used as default.
  final Color? backgroundColor;

  /// Border radius for the action button.
  ///
  /// Defaults to a rounded shape with circular radius of 50.
  final BorderRadius? borderRadius;

  /// Text style for the button label.
  ///
  /// Controls the appearance of the text inside the button.
  final TextStyle? textStyle;

  /// Padding inside the action button.
  final EdgeInsets? padding;

  /// A custom widget to use instead of the default button appearance.
  ///
  /// When provided, most other appearance properties are ignored.
  final Widget? button;

  /// Icon to display before the button text.
  final ActionButtonIcon? leadIcon;

  /// Icon to display after the button text.
  final ActionButtonIcon? tailIcon;

  /// Predefined action type that determines the button's default behavior.
  final TooltipDefaultActionType? type;

  /// Display text for the button.
  ///
  /// If not provided, uses the name from the action type.
  final String? name;

  /// Callback function triggered when the button is tapped.
  ///
  /// When provided, this overrides the default behavior of the action type.
  final VoidCallback? onTap;

  /// Border to apply around the button.
  ///
  /// Allows for custom border styling such as color, width, and style.
  final Border? border;

  /// Hides action widgets for the showcase. Add key of particular showcase
  /// in this list.
  /// This only works for the global action widgets
  /// Defaults to []
  final List<GlobalKey> hideActionWidgetForShowcase;
}
