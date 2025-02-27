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

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'models/linked_showcase_data.dart';

class RRectClipper extends CustomClipper<ui.Path> {
  final bool isCircle;
  final BorderRadius? radius;
  final EdgeInsets overlayPadding;
  final Rect area;
  final List<LinkedShowcaseDataModel> linkedObjectData;

  RRectClipper({
    this.isCircle = false,
    this.radius,
    this.overlayPadding = EdgeInsets.zero,
    this.area = Rect.zero,
    this.linkedObjectData = const <LinkedShowcaseDataModel>[],
  });

  @override
  ui.Path getClip(ui.Size size) {
    final customRadius =
        isCircle ? Radius.circular(area.height) : const Radius.circular(3.0);

    final rect = Rect.fromLTRB(
      area.left - overlayPadding.left,
      area.top - overlayPadding.top,
      area.right + overlayPadding.right,
      area.bottom + overlayPadding.bottom,
    );

    var mainObjectPath = Path()
      ..fillType = ui.PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: (radius?.topLeft ?? customRadius),
          topRight: (radius?.topRight ?? customRadius),
          bottomLeft: (radius?.bottomLeft ?? customRadius),
          bottomRight: (radius?.bottomRight ?? customRadius),
        ),
      );

    for (final widgetRect in linkedObjectData) {
      final customRadius = widgetRect.isCircle
          ? Radius.circular(widgetRect.rect.height)
          : const Radius.circular(3.0);

      final rect = Rect.fromLTRB(
        widgetRect.rect.left - widgetRect.overlayPadding.left,
        widgetRect.rect.top - widgetRect.overlayPadding.top,
        widgetRect.rect.right + widgetRect.overlayPadding.right,
        widgetRect.rect.bottom + widgetRect.overlayPadding.bottom,
      );

      /// We have use this approach so that overlapping cutout will merge with
      /// each other
      mainObjectPath = Path.combine(
        PathOperation.difference,
        mainObjectPath,
        Path()
          ..addRRect(
            RRect.fromRectAndCorners(
              rect,
              topLeft: (widgetRect.radius?.topLeft ?? customRadius),
              topRight: (widgetRect.radius?.topRight ?? customRadius),
              bottomLeft: (widgetRect.radius?.bottomLeft ?? customRadius),
              bottomRight: (widgetRect.radius?.bottomRight ?? customRadius),
            ),
          ),
      );
    }

    return mainObjectPath;
  }

  @override
  bool shouldReclip(covariant RRectClipper oldClipper) =>
      isCircle != oldClipper.isCircle ||
      radius != oldClipper.radius ||
      overlayPadding != oldClipper.overlayPadding ||
      area != oldClipper.area ||
      linkedObjectData != oldClipper.linkedObjectData;
}
