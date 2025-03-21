part of 'tooltip.dart';

class _Arrow extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;
  final Paint _paint;

  _Arrow({
    this.strokeColor = Colors.black,
    this.strokeWidth = Constants.arrowStrokeWidth,
    this.paintingStyle = PaintingStyle.fill,
  }) : _paint = Paint()
          ..color = strokeColor
          ..strokeWidth = strokeWidth
          ..style = paintingStyle;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(_getTrianglePath(), _paint);
  }

  @override
  bool shouldRepaint(covariant _Arrow oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }

  Path _getTrianglePath() {
    return Path()
      ..moveTo(0, Constants.arrowHeight)
      ..lineTo(Constants.arrowWidth * 0.5, 0)
      ..lineTo(Constants.arrowWidth, Constants.arrowHeight)
      ..lineTo(0, Constants.arrowHeight);
  }
}
