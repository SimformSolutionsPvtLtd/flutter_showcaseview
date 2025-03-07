part of 'tooltip.dart';

const arrowWidth = 18.0;
const arrowHeight = 9.0;

class _Arrow extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;
  final Paint _paint;

  _Arrow({
    this.strokeColor = Colors.black,
    this.strokeWidth = 3,
    this.paintingStyle = PaintingStyle.stroke,
  }) : _paint = Paint()
          ..color = strokeColor
          ..strokeWidth = strokeWidth
          ..style = paintingStyle;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(getTrianglePath(), _paint);
  }

  Path getTrianglePath() {
    // Fixed width & height

    return Path()
      ..moveTo(0, arrowHeight)
      ..lineTo(arrowWidth / 2, 0)
      ..lineTo(arrowWidth, arrowHeight)
      ..lineTo(0, arrowHeight);
  }

  @override
  bool shouldRepaint(covariant _Arrow oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
