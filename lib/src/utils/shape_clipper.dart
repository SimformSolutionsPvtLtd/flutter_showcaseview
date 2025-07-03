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

import '../models/linked_showcase_data_model.dart';
import 'constants.dart';

class ShapeClipper extends CustomClipper<ui.Path> {
  /// A custom clipper that creates cutout shapes in the overlay for showcased
  /// widgets.
  ///
  /// This clipper is used by the [ShowcaseView]'s overlay system to create
  /// transparent regions that reveal the target widgets being showcased. It
  /// works by:
  ///
  /// 1. Creating a base path covering the entire overlay area.
  /// 2. For each target widget in [linkedObjectData], cutting out a shape using
  ///    the difference operation.
  /// 3. Supporting different shape types (circular or rectangular with custom
  /// radius).
  /// 4. Handling multiple target shapes that can merge when overlapping.
  const ShapeClipper({
    this.linkedObjectData = const <LinkedShowcaseDataModel>[],
  });

  final List<LinkedShowcaseDataModel> linkedObjectData;

  @override
  ui.Path getClip(ui.Size size) {
    // Using a different clipping approach on web since the optimized approach
    // is not working in Flutter (3.10.0 - 3.32.5).
    if (kIsWeb) {
      return _webClip(size);
    }
    return _optimisedClip(size);
  }

  /// This clipping method is less optimized but ensures correct cutout rendering
  /// on web and all platforms. The [_optimisedClip] method does not work reliably
  /// on web, so a conditional check is used to select this implementation for web.
  ui.Path _webClip(ui.Size size) {
    var mainObjectPath = Path()
      ..fillType = ui.PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndCorners(ui.Rect.zero));

    final linkedObjectLength = linkedObjectData.length;
    for (var i = 0; i < linkedObjectLength; i++) {
      final widgetInfo = linkedObjectData[i];
      final customRadius = widgetInfo.isCircle
          ? Radius.circular(
              widgetInfo.rect.height + widgetInfo.overlayPadding.vertical,
            )
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

  /// Returns a [ui.Path] representing the overlay with cutouts for each showcased widget.
  ///
  /// This implementation is optimized for non-web platforms.
  ui.Path _optimisedClip(ui.Size size) {
    // Start with a path for the entire screen
    final screenPath = Path()..addRect(Offset.zero & size);

    // If there are no showcase items, return the full screen path
    if (linkedObjectData.isEmpty) {
      return screenPath;
    }

    // Create a path that will contain all the cutout shapes
    final cutoutsPath = Path();

    // Add all showcase shapes to the cutouts path
    for (final widgetInfo in linkedObjectData) {
      final customRadius = widgetInfo.isCircle
          ? Radius.circular(
              widgetInfo.rect.height + widgetInfo.overlayPadding.vertical,
            )
          : Constants.defaultTargetRadius;

      final rect = Rect.fromLTRB(
        widgetInfo.rect.left - widgetInfo.overlayPadding.left,
        widgetInfo.rect.top - widgetInfo.overlayPadding.top,
        widgetInfo.rect.right + widgetInfo.overlayPadding.right,
        widgetInfo.rect.bottom + widgetInfo.overlayPadding.bottom,
      );

      cutoutsPath.addRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: (widgetInfo.radius?.topLeft ?? customRadius),
          topRight: (widgetInfo.radius?.topRight ?? customRadius),
          bottomLeft: (widgetInfo.radius?.bottomLeft ?? customRadius),
          bottomRight: (widgetInfo.radius?.bottomRight ?? customRadius),
        ),
      );
    }

    // Create the final path by subtracting all cutouts from the screen path
    // Using PathOperation.difference to cut out the shapes
    final finalPath = Path.combine(
      PathOperation.difference,
      screenPath,
      cutoutsPath,
    );

    return finalPath;
  }

  @override
  bool shouldReclip(covariant ShapeClipper oldClipper) =>
      !listEquals(linkedObjectData, oldClipper.linkedObjectData);
}
