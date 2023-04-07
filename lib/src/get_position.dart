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
  GetPosition({
    required this.key,
    required this.screenWidth,
    required this.screenHeight,
    this.padding = EdgeInsets.zero,
    this.adjustWidthSize = 0.0,
  }) {
    getRenderBox();
  }

  final GlobalKey key;
  final EdgeInsets padding;
  final double screenWidth;
  final double screenHeight;
  final double adjustWidthSize;

  late final RenderBox? _box;
  late final Offset? _boxOffset;

  void getRenderBox() {
    var renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      _box = renderBox;
      final offset = _box?.globalToLocal(Offset.zero);
      if (offset != null) {
        _boxOffset = Offset(
          offset.dx.abs() - adjustWidthSize,
          offset.dy.abs(),
        );
      }
    }
  }

  Rect getRect() {
    if (_box == null ||
        _boxOffset == null ||
        (_boxOffset?.dx.isNaN ?? true) ||
        (_boxOffset?.dy.isNaN ?? true)) {
      return Rect.zero;
    }
    final topLeft = _box!.size.topLeft(_boxOffset!);
    final bottomRight = _box!.size.bottomRight(_boxOffset!);

    final rect = Rect.fromLTRB(
      topLeft.dx - padding.left < 0 ? 0 : topLeft.dx - padding.left,
      topLeft.dy - padding.top < 0 ? 0 : topLeft.dy - padding.top,
      bottomRight.dx + padding.right > screenWidth
          ? screenWidth
          : bottomRight.dx + padding.right,
      bottomRight.dy + padding.bottom > screenHeight
          ? screenHeight
          : bottomRight.dy + padding.bottom,
    );
    return rect;
  }

  ///Get the bottom position of the widget
  double getBottom() {
    if (_box == null || _boxOffset == null || (_boxOffset?.dy.isNaN ?? true)) {
      return padding.bottom;
    }
    final bottomRight = _box!.size.bottomRight(_boxOffset!);
    return bottomRight.dy + padding.bottom;
  }

  ///Get the top position of the widget
  double getTop() {
    if (_box == null || _boxOffset == null || (_boxOffset?.dy.isNaN ?? true)) {
      return 0 - padding.top;
    }
    final topLeft = _box!.size.topLeft(_boxOffset!);
    return topLeft.dy - padding.top;
  }

  ///Get the left position of the widget
  double getLeft() {
    if (_box == null || _boxOffset == null || (_boxOffset?.dx.isNaN ?? true)) {
      return 0 - padding.left;
    }
    final topLeft = _box!.size.topLeft(_boxOffset!);
    return topLeft.dx - padding.left;
  }

  ///Get the right position of the widget
  double getRight() {
    if (_box == null || _boxOffset == null || (_boxOffset?.dx.isNaN ?? true)) {
      return padding.right;
    }
    final bottomRight = _box!.size.bottomRight(_boxOffset!);
    return bottomRight.dx + padding.right;
  }

  double getHeight() => getBottom() - getTop();

  double getWidth() => getRight() - getLeft();

  double getCenter() => (getLeft() + getRight()) / 2;
}
