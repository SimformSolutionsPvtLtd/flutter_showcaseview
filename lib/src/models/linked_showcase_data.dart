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
import 'package:flutter/widgets.dart';

@immutable
class LinkedShowcaseDataModel {
  /// This model is used to move linked showcase overlay data to parent
  /// showcase to crop linked showcase rect.
  const LinkedShowcaseDataModel({
    required this.rect,
    required this.radius,
    required this.overlayPadding,
    required this.isCircle,
  });

  final Rect rect;
  final EdgeInsets overlayPadding;
  final BorderRadius? radius;
  final bool isCircle;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LinkedShowcaseDataModel &&
          runtimeType == other.runtimeType &&
          rect == other.rect &&
          radius == other.radius &&
          overlayPadding == other.overlayPadding &&
          isCircle == other.isCircle;

  @override
  int get hashCode => Object.hash(
        rect,
        radius,
        overlayPadding,
        isCircle,
      );
}
