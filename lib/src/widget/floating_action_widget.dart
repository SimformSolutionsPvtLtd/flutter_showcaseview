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

class FloatingActionWidget extends StatelessWidget {
  /// A widget that displays a floating action button that doesn't animate
  /// during the showcase tour. It can be used for:
  ///
  /// * Adding custom buttons like 'Skip', 'Next', or 'Close'.
  /// * Creating persistent UI elements that remain visible throughout the
  /// showcase.
  ///
  /// Example usage:
  /// ```dart
  /// Showcase(
  ///   key: showcaseKey,
  ///   description: 'Feature description',
  ///   child: YourWidget(),
  ///   floatingActionWidget: FloatingActionWidget(
  ///     left: 16,
  ///     bottom: 16,
  ///     child: ElevatedButton(
  ///       onPressed: () => ShowcaseView.of(context).dismiss(),
  ///       child: Text('Skip'),
  ///     ),
  ///   ),
  /// )
  /// ```
  const FloatingActionWidget({
    required this.child,
    this.right,
    this.width,
    this.height,
    this.left,
    this.bottom,
    this.top,
    super.key,
  });

  /// This is same as the Positioned.directional widget
  /// Creates a widget that controls where a child of a [Stack] is positioned.
  ///
  /// Only two out of the three horizontal values (`start`, `end`,
  /// [width]), and only two out of the three vertical values ([top],
  /// [bottom], [height]), can be set. In each case, at least one of
  /// the three must be null.
  ///
  /// If `textDirection` is [TextDirection.rtl], then the `start` argument is
  /// used for the [right] property and the `end` argument is used for the
  /// [left] property. Otherwise, if `textDirection` is [TextDirection.ltr],
  /// then the `start` argument is used for the [left] property and the `end`
  /// argument is used for the [right] property.
  factory FloatingActionWidget.directional({
    required TextDirection textDirection,
    required Widget child,
    double? start,
    double? top,
    double? end,
    double? bottom,
    double? width,
    double? height,
    Key? key,
  }) {
    /// Default value will be [TextDirection.ltr].
    var left = start;
    var right = end;
    switch (textDirection) {
      case TextDirection.ltr:
        break;
      case TextDirection.rtl:
        left = end;
        right = start;
    }
    return FloatingActionWidget(
      key: key,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      width: width,
      height: height,
      child: child,
    );
  }

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// The distance that the child's left edge is inset from the left of the
  /// stack.
  ///
  /// Only two out of the three horizontal values ([left], [right], [width])
  /// can be set. The third must be null.
  ///
  /// If all three are null, the [Stack.alignment] is used to position the child
  /// horizontally.
  final double? left;

  /// The distance that the child's top edge is inset from the top of the stack.
  ///
  /// Only two out of the three vertical values ([top], [bottom], [height])
  /// can be set. The third must be null.
  ///
  /// If all three are null, the [Stack.alignment] is used to position the child
  /// vertically.
  final double? top;

  /// Only two out of the three horizontal values ([left], [right], [width])
  /// can be set. The third must be null.
  ///
  /// If all three are null, the [Stack.alignment] is used to position the child
  /// horizontally.
  final double? right;

  /// The distance that the child's bottom edge is inset from the bottom of
  /// the stack.
  ///
  /// Only two out of the three vertical values ([top], [bottom], [height])
  /// can be set. The third must be null.
  ///
  /// If all three are null, the [Stack.alignment] is used to position the child
  /// vertically.
  final double? bottom;

  /// The child's width.
  ///
  /// Only two out of the three horizontal values ([left], [right], [width])
  /// can be set. The third must be null.
  ///
  /// If all three are null, the [Stack.alignment] is used to position the child
  /// horizontally.
  final double? width;

  /// The child's height.
  ///
  /// Only two out of the three vertical values ([top], [bottom], [height])
  /// can be set. The third must be null.
  ///
  /// If all three are null, the [Stack.alignment] is used to position the child
  /// vertically.
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      key: key,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      width: width,
      height: height,
      child: Material(color: Colors.transparent, child: child),
    );
  }
}
