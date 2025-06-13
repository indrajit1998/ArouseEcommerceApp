import 'package:flutter/material.dart';
import 'dart:math' as math;

class EMISemiCircleChart extends CustomPainter {
  final double principal;
  final double totalInterest;

  EMISemiCircleChart({required this.principal, required this.totalInterest});

  @override
  void paint(Canvas canvas, Size size) {
    final double total = principal + totalInterest;
    if (total == 0) return;

    final double principalRatio = principal / total;
    final double interestRatio = totalInterest / total;

    final double radius = size.width / 2;
    final double strokeWidth = 20.0;
    final Paint principalPaint = Paint()
      ..color = Color.fromRGBO(34, 53, 119, 1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final Paint interestPaint = Paint()
      ..color = Color.fromRGBO(39, 153, 227, 1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final Rect rect = Rect.fromCircle(
      center: Offset(radius, radius),
      radius: radius - strokeWidth / 2,
    );

    const double startAngle = math.pi;
    const double totalSweepAngle = math.pi;

    final double principalSweepAngle = totalSweepAngle * principalRatio;
    canvas.drawArc(
      rect,
      startAngle,
      principalSweepAngle,
      false,
      principalPaint,
    );

    final double interestStartAngle = startAngle + principalSweepAngle;
    final double interestSweepAngle = totalSweepAngle * interestRatio;
    canvas.drawArc(
      rect,
      interestStartAngle,
      interestSweepAngle,
      false,
      interestPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}