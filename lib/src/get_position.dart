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

class GetPosition {
  final GlobalKey? key;
  final EdgeInsets padding;

  GetPosition({
    this.key,
    this.padding = EdgeInsets.zero,
  });

  ///Get the bottom position of the widget
  double getBottom() {
    final box = key!.currentContext!.findRenderObject() as RenderBox;
    final boxOffset =
        box.localToGlobal(-(getMaterialAppOffset(key!.currentContext!)));
    if (boxOffset.dy.isNaN) return padding.bottom;
    final bottomRight = box.size.bottomRight(boxOffset);
    return bottomRight.dy + padding.bottom;
  }

  ///Get the top position of the widget
  double getTop() {
    final box = key!.currentContext!.findRenderObject() as RenderBox;
    final boxOffset =
        box.localToGlobal(-(getMaterialAppOffset(key!.currentContext!)));
    if (boxOffset.dy.isNaN) return 0 - padding.top;
    final topLeft = box.size.topLeft(boxOffset);
    return topLeft.dy - padding.top;
  }

  ///Get the left position of the widget
  double getLeft() {
    final box = key!.currentContext!.findRenderObject() as RenderBox;
    final boxOffset =
        box.localToGlobal(-(getMaterialAppOffset(key!.currentContext!)));
    if (boxOffset.dx.isNaN) return 0 - padding.left;
    final topLeft = box.size.topLeft(boxOffset);
    return topLeft.dx - padding.left;
  }

  ///Get the right position of the widget
  double getRight() {
    final box = key!.currentContext!.findRenderObject() as RenderBox;
    final boxOffset =
        box.localToGlobal(-(getMaterialAppOffset(key!.currentContext!)));
    if (boxOffset.dx.isNaN) return padding.right;
    final bottomRight = box.size.bottomRight(boxOffset);
    return bottomRight.dx + padding.right;
  }

  double getHeight() {
    return getBottom() - getTop();
  }

  double getWidth() {
    return getRight() - getLeft();
  }

  double getCenter() {
    return (getLeft() + getRight()) / 2;
  }

  // Gets the position of the ancestor MaterialApp. Better alternative to assuming Offset.zero in web context when calculating LTRB
  static Offset getMaterialAppOffset(BuildContext context) {
    final state = context.findAncestorStateOfType<State<MaterialApp>>()!;
    if (!state.mounted) return Offset.zero;
    RenderBox box = state.context.findRenderObject() as RenderBox;
    return box.localToGlobal(Offset.zero);
  }

  // Gets the size of the ancestor MaterialApp. Better alternative to MediaQuery.of(context).size in web context
  static Size getMaterialAppSize(BuildContext context) {
    final state = context.findAncestorStateOfType<State<MaterialApp>>()!;
    RenderBox box = state.context.findRenderObject() as RenderBox;
    return box.size;
  }
}
