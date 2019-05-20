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

  double getHeight() {
    RenderBox box = key.currentContext.findRenderObject();
    final topLeft = box.size.topLeft(box.localToGlobal(const Offset(0.0, 0.0)));
    final bottomRight =
        box.size.bottomRight(box.localToGlobal(const Offset(0.0, 0.0)));
    double height = bottomRight.dy - topLeft.dy;
    return height;
  }

  double getBottom(){
    RenderBox box = key.currentContext.findRenderObject();
    final bottomRight =
        box.size.bottomRight(box.localToGlobal(const Offset(0.0, 0.0)));
    return bottomRight.dy;
  }

  double getTop(){
    RenderBox box = key.currentContext.findRenderObject();
    final topLeft = box.size.topLeft(box.localToGlobal(const Offset(0.0, 0.0)));
    return topLeft.dy;
  }
}
