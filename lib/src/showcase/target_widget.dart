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

class TargetWidget extends StatelessWidget {
  /// A widget that represents the target of a showcase.
  ///
  /// This widget creates a transparent overlay that highlights a UI element
  /// that needs to be showcased. It defines the position, size, and interaction
  /// behavior of the target area.
  ///
  /// It is positioned absolutely within the showcase overlay and can respond
  /// to various gestures like tap, double tap, and long press.
  const TargetWidget({
    required this.offset,
    required this.size,
    required this.shapeBorder,
    required this.targetPadding,
    this.onTap,
    this.radius,
    this.onDoubleTap,
    this.onLongPress,
    this.disableDefaultChildGestures = false,
    super.key,
  });

  /// The position of the target widget in the overlay coordinates.
  final Offset offset;

  /// The size of the target widget to be highlighted.
  final Size size;

  /// Callback function when the target is tapped.
  final VoidCallback? onTap;

  /// Callback function when the target is double-tapped.
  final VoidCallback? onDoubleTap;

  /// Callback function when the target is long-pressed.
  final VoidCallback? onLongPress;

  /// The shape of the target highlight.
  final ShapeBorder shapeBorder;

  /// Border radius when using a rectangular shape.
  final BorderRadius? radius;

  /// Whether to disable gesture detection on the target area.
  ///
  /// When true, the target area will not respond to gestures and will
  /// not show a pointer cursor on hover.
  final bool disableDefaultChildGestures;

  /// Padding applied around the target to increase its highlight area.
  final EdgeInsets targetPadding;

  @override
  Widget build(BuildContext context) {
    final targetWidgetContent = GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        height: size.height.abs(),
        width: size.width.abs(),
        margin: targetPadding,
        decoration: ShapeDecoration(
          shape: radius == null
              ? shapeBorder
              : RoundedRectangleBorder(borderRadius: radius!),
        ),
      ),
    );
    return Positioned(
      top: offset.dy - targetPadding.top,
      left: offset.dx - targetPadding.left,
      child: disableDefaultChildGestures
          ? IgnorePointer(child: targetWidgetContent)
          : MouseRegion(
              cursor: SystemMouseCursors.click,
              child: targetWidgetContent,
            ),
    );
  }
}
