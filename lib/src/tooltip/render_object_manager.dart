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
import 'package:flutter/rendering.dart';

import '../utils/enum.dart';

class RenderObjectManager {
  RenderObjectManager({
    required this.customRenderBox,
    required TooltipLayoutSlot slot,
  }) {
    renderObjects[slot] = this;
  }

  final RenderBox customRenderBox;
  BoxConstraints? renderConstraints;
  Size? dryLayoutSize;
  double? height;
  double? xOffset;
  double? yOffset;

  static Map<TooltipLayoutSlot, RenderObjectManager> renderObjects = {};

  /// Clears renderObjects map
  static void clear() => renderObjects.clear();

  /// Performs dry layout to calculate the preferred size without actually laying out
  Size performDryLayout(BoxConstraints constraints) {
    renderConstraints = constraints;
    dryLayoutSize = customRenderBox.getDryLayout(constraints);
    return dryLayoutSize!;
  }

  /// Performs actual layout on the RenderBox
  void performLayout(BoxConstraints constraints, {bool parentUsesSize = true}) {
    customRenderBox.layout(constraints, parentUsesSize: parentUsesSize);
    dryLayoutSize = customRenderBox.size;
  }

  /// Gets the current size of the RenderBox
  Size get size => dryLayoutSize ?? customRenderBox.size;

  Offset get getOffset => Offset(xOffset ?? 0, yOffset ?? 0);

  MultiChildLayoutParentData get layoutParentData {
    assert(customRenderBox.parentData is MultiChildLayoutParentData);
    return customRenderBox.parentData! as MultiChildLayoutParentData;
  }

  /// Sets the position of the RenderBox
  void setOffset(double x, double y) {
    xOffset = x;
    yOffset = y;
    assert(customRenderBox.parentData is MultiChildLayoutParentData);
    final parentData = customRenderBox.parentData as MultiChildLayoutParentData;
    parentData.offset = Offset(x, y);
  }
}
