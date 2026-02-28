import 'package:flutter/material.dart';

class DashedBorderPainter extends CustomPainter {
  DashedBorderPainter({
    this.color = Colors.grey,
    this.strokeWidth = 1.5,
    this.dashLength = 6.0,
    this.gapLength = 4.0,
    this.borderRadius = 16.0,
  });

  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final dashPath = _createDashPath(path);

    canvas.drawPath(
      dashPath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  Path _createDashPath(Path source) {
    final result = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final dashEnd = (distance + dashLength).clamp(0.0, metric.length);
        result.addPath(
          metric.extractPath(distance, dashEnd),
          Offset.zero,
        );
        distance += dashLength + gapLength;
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      dashLength != oldDelegate.dashLength ||
      gapLength != oldDelegate.gapLength ||
      borderRadius != oldDelegate.borderRadius;
}
