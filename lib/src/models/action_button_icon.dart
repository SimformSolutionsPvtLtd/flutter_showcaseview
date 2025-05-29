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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActionButtonIcon {
  /// Creates an icon configuration for a tooltip action button with a
  /// standard [Icon].
  ///
  /// The [icon] parameter is required and specifies the icon to display.
  /// The optional [padding] parameter defines spacing around the icon.
  const ActionButtonIcon({
    required Icon this.icon,
    this.padding,
  });

  /// Creates an icon configuration for a tooltip action button with an
  /// [ImageIcon].
  ///
  /// The [icon] parameter is required and specifies the image icon to display.
  /// The optional [padding] parameter defines spacing around the icon.
  const ActionButtonIcon.withImageIcon({
    required ImageIcon this.icon,
    this.padding,
  });

  /// The icon widget to display in the button.
  ///
  /// Can be either an [Icon] or [ImageIcon] depending on which constructor
  /// is used.
  final Widget icon;

  /// Optional padding to apply around the icon.
  final EdgeInsets? padding;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ActionButtonIcon &&
        icon == other.icon &&
        padding == other.padding;
  }

  @override
  int get hashCode => Object.hash(icon, padding);
}
