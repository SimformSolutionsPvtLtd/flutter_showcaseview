import 'package:flutter/material.dart';

class ShapePainter extends CustomPainter {
  GlobalKey key;
  ShapePainter({@required this.key});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.black.withOpacity(0.5);
    RRect outer =
        RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(0));
    // RRect inner = RRect.fromLTRBR(100, 100, size.width -100 , size.height -100 ,Radius.circular(3));
    RRect inner = RRect.fromRectAndRadius(_getPosition(), Radius.circular(3));
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
