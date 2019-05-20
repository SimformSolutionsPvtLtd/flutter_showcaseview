import 'package:flutter/material.dart';

class ShapePainter extends CustomPainter {
  Rect rect;
  final ShapeBorder shapeBorder;
  final Color color;
  final double opacity;
  ShapePainter(
      {@required this.rect, this.color, this.shapeBorder, this.opacity});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    double radius = 3.0;
    paint.color = color.withOpacity(opacity);
    RRect outer =
        RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(0));
    if (shapeBorder == CircleBorder()) {
      radius = 50;
    }
    RRect inner = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawDRRect(outer, inner, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
