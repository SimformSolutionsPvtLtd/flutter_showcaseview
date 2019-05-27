import 'package:flutter/material.dart';

class GetPosition {
  final GlobalKey key;
  GetPosition({this.key});

  Rect getRect() {
    RenderBox box = key.currentContext.findRenderObject();
    final topLeft = box.size.topLeft(box.localToGlobal(const Offset(0.0, 0.0)));
    final bottomRight =
        box.size.bottomRight(box.localToGlobal(const Offset(0.0, 0.0)));
    Rect rect = Rect.fromLTRB(
      topLeft.dx - 6,
      topLeft.dy - 6,
      bottomRight.dx + 6,
      bottomRight.dy + 6,
    );
    return rect;
  }

  double getBottom() {
    RenderBox box = key.currentContext.findRenderObject();
    final bottomRight =
        box.size.bottomRight(box.localToGlobal(const Offset(0.0, 0.0)));
    return bottomRight.dy;
  }

  double getTop() {
    RenderBox box = key.currentContext.findRenderObject();
    final topLeft = box.size.topLeft(box.localToGlobal(const Offset(0.0, 0.0)));
    return topLeft.dy;
  }

  double getLeft() {
    RenderBox box = key.currentContext.findRenderObject();
    final topLeft = box.size.topLeft(box.localToGlobal(const Offset(0.0, 0.0)));
    return topLeft.dx;
  }

  double getRight() {
    RenderBox box = key.currentContext.findRenderObject();
    final bottomRight =
        box.size.bottomRight(box.localToGlobal(const Offset(0.0, 0.0)));
    return bottomRight.dx;
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
}
