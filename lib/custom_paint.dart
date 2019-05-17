import 'package:flutter/material.dart';

class ShapePainter extends CustomPainter {
  GlobalKey key;
  final ShapeBorder shapeBorder;
  ShapePainter({@required this.key, this.shapeBorder});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    double radius = 3.0;
    paint.color = Colors.black.withOpacity(0.5);
    RRect outer =
        RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(0));
    if (shapeBorder == CircleBorder()) {
      radius = 50;
    }
    RRect inner =
        RRect.fromRectAndRadius(_getPosition(), Radius.circular(radius));
    canvas.drawDRRect(outer, inner, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  _getPosition() {
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
}
