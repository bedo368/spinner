import 'dart:math';
import 'package:flutter/material.dart';
import 'package:spinner/models/circle_clice.dart';

/// الرسّام: يرسم الأقواس (الشرائح) فقط (دون نص)
class CircleSlicesPainter extends CustomPainter {
  final List<CircleSlice> slices;
  final double? highlightAngle; // في الراديان أو null
  final double blinkFactor; // قيمة الوميض (0..1)

  CircleSlicesPainter({
    required this.slices,
    required this.highlightAngle,
    required this.blinkFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double? angleToCheck;
    if (highlightAngle != null) {
      angleToCheck = _normalizeAngle(highlightAngle!);
    }

    for (final slice in slices) {
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = slice.defaultColor; // Default color of the slice

      // إذا كانت الزاوية المُختارة ضمن هذه الشريحة، نطبق تأثير الوميض
      if (angleToCheck != null && _isAngleInSlice(angleToCheck, slice)) {
        final minOpacity = 0.5;
        final maxOpacity = 1.0;
        final currentOpacity =
            minOpacity + (maxOpacity - minOpacity) * blinkFactor;

        // Use the slice's `activeColor` for highlighting
        paint.color = slice.activeColor.withOpacity(currentOpacity);
      }

      canvas.drawArc(
        rect,
        slice.startAngle,
        slice.sweepAngle,
        true, // true لرسم شريحة بيانية (pie slice)
        paint,
      );
    }
  }

  /// هل angle تقع ضمن زاوية الشريحة slice؟
  bool _isAngleInSlice(double angle, CircleSlice slice) {
    final start = _normalizeAngle(slice.startAngle);
    final end = _normalizeAngle(slice.startAngle + slice.sweepAngle);

    if (end < start) {
      // الشريحة تعبر 2π، مثل start=350°, end=30°
      return (angle >= start && angle < 2 * pi) || (angle >= 0 && angle < end);
    } else {
      return (angle >= start && angle < end);
    }
  }

  /// تطبيع الزاوية إلى المجال [0..2π)
  double _normalizeAngle(double angle) {
    final twoPi = 2 * pi;
    angle = angle % twoPi;
    if (angle < 0) angle += twoPi;
    return angle;
  }

  @override
  bool shouldRepaint(covariant CircleSlicesPainter oldDelegate) {
    return oldDelegate.blinkFactor != blinkFactor ||
        oldDelegate.highlightAngle != highlightAngle ||
        oldDelegate.slices != slices;
  }
}
