import 'package:flutter/rendering.dart';

import '../enum.dart';

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

  /// Sets the position of the RenderBox
  void setOffset(double x, double y) {
    xOffset = x;
    yOffset = y;
    assert(customRenderBox.parentData is MultiChildLayoutParentData);
    final parentData = customRenderBox.parentData as MultiChildLayoutParentData;
    parentData.offset = Offset(x, y);
  }
}
