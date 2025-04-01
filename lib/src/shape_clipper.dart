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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'constants.dart';
import 'models/linked_showcase_data.dart';

class RRectClipper extends CustomClipper<ui.Path> {
  const RRectClipper({
    this.isCircle = false,
    this.overlayPadding = EdgeInsets.zero,
    this.area = Rect.zero,
    this.linkedObjectData = const <LinkedShowcaseDataModel>[],
    this.radius,
  });

  final bool isCircle;
  final BorderRadius? radius;
  final EdgeInsets overlayPadding;
  final Rect area;
  final List<LinkedShowcaseDataModel> linkedObjectData;

  @override
  ui.Path getClip(ui.Size size) {
    final customRadius =
        isCircle ? Radius.circular(area.height) : Constants.defaultTargetRadius;

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

    final linkedObjectLength = linkedObjectData.length;
    for (var i = 0; i < linkedObjectLength; i++) {
      final widgetInfo = linkedObjectData[i];
      final customRadius = widgetInfo.isCircle
          ? Radius.circular(widgetInfo.rect.height)
          : Constants.defaultTargetRadius;

      final rect = Rect.fromLTRB(
        widgetInfo.rect.left - widgetInfo.overlayPadding.left,
        widgetInfo.rect.top - widgetInfo.overlayPadding.top,
        widgetInfo.rect.right + widgetInfo.overlayPadding.right,
        widgetInfo.rect.bottom + widgetInfo.overlayPadding.bottom,
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
              topLeft: (widgetInfo.radius?.topLeft ?? customRadius),
              topRight: (widgetInfo.radius?.topRight ?? customRadius),
              bottomLeft: (widgetInfo.radius?.bottomLeft ?? customRadius),
              bottomRight: (widgetInfo.radius?.bottomRight ?? customRadius),
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
      !listEquals(linkedObjectData, oldClipper.linkedObjectData);
}
