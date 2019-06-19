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
      topLeft.dx,
      topLeft.dy,
      bottomRight.dx,
      bottomRight.dy,
    );
    return rect;
  }

  ///Get the bottom position of the widget
  double getBottom() {
    RenderBox box = key.currentContext.findRenderObject();
    final bottomRight =
        box.size.bottomRight(box.localToGlobal(const Offset(0.0, 0.0)));
    return bottomRight.dy;
  }

  ///Get the top position of the widget
  double getTop() {
    RenderBox box = key.currentContext.findRenderObject();
    final topLeft = box.size.topLeft(box.localToGlobal(const Offset(0.0, 0.0)));
    return topLeft.dy;
  }

  ///Get the left position of the widget
  double getLeft() {
    RenderBox box = key.currentContext.findRenderObject();
    final topLeft = box.size.topLeft(box.localToGlobal(const Offset(0.0, 0.0)));
    return topLeft.dx;
  }

  ///Get the right position of the widget
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
