import 'dart:math';
import 'package:flutter/material.dart';
import 'package:spinner/models/circle_clice.dart';
import 'package:spinner/painter/circle_slices_painter.dart';
import 'package:spinner/slice_list/slices.dart';

/// ويدجت لرسم دائرة مع شرائح فوق خلفية صورة
/// + إضافة ويدجات فوق مراكز الشرائح (childWidget).
class CircleSlicesWidget extends StatefulWidget {
  final String imagePath;
  final List<CircleSlice> slices;
  final double? angleInDegrees; // 0 تعني أعلى الدائرة أو يمكن أن تكون null
  final double size; // عرض/ارتفاع الدائرة

  const CircleSlicesWidget({
    super.key,
    required this.imagePath,
    required this.slices,
    this.angleInDegrees,
    this.size = 300,
  });

  @override
  State<CircleSlicesWidget> createState() => _CircleSlicesWidgetState();
}

class _CircleSlicesWidgetState extends State<CircleSlicesWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    // مدة ثانية واحدة للوميض
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _blinkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// تحويل درجة المستخدم إلى راديان، ثم طرح pi/2 لجعل 0 = أعلى الدائرة
  double? get _highlightAngleInRadians {
    if (widget.angleInDegrees == null) return null;
    final deg = widget.angleInDegrees!.clamp(0, 360);
    final rad = deg * pi / 180;
    return rad - pi / 2;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          // صورة الخلفية
          Positioned.fill(
            child: Image.asset(
              widget.imagePath,
              fit: BoxFit.cover,
            ),
          ),
          // رسم الشرائح مع الوميض
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _blinkAnimation,
              builder: (_, __) {
                return CustomPaint(
                  painter: CircleSlicesPainter(
                    slices: widget.slices,
                    highlightAngle: _highlightAngleInRadians,
                    blinkFactor: _blinkAnimation.value,
                  ),
                );
              },
            ),
          ),
          // ويدجت فوق مركز كل شريحة
          ..._buildSliceWidgets(),
        ],
      ),
    );
  }

  /// نبني قائمة Widgets (Positioned) لكل شريحة وفق إحداثياتها
  List<Widget> _buildSliceWidgets() {
    final sliceWidgets = <Widget>[];

    final radius = widget.size / 2;
    final center = Offset(radius, radius);

    for (final slice in widget.slices) {
      if (slice.childWidget == null) continue;

      // زاوية منتصف الشريحة
      double middleAngle = slice.startAngle + slice.sweepAngle / 2;

      // نحسب إحداثيات هذه النقطة على بعد 65% من نصف القطر
      final r = radius * 0.65; // زادت النسبة لإبعاد النص أكثر عن المركز
      final dx = center.dx + r * cos(middleAngle);
      final dy = center.dy + r * sin(middleAngle);

      // تطبيع الزاوية إلى [0..2π)
      double normalizedAngle = middleAngle % (2 * pi);
      if (normalizedAngle < 0) {
        normalizedAngle += 2 * pi;
      }

      // إذا كانت الزاوية بين 90° و 270°،
      // فهذا يعني أن النص سيظهر مقلوبًا للمستخدم، فنضيف 180°.
      if (normalizedAngle > pi / 2 && normalizedAngle < 3 * pi / 2) {
        middleAngle += pi;
      }

      sliceWidgets.add(
        Positioned(
          left: dx,
          top: dy,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              // نقل مركز الودجت ليكون عند (0,0)، اضبط القيم حسب حجم النص
              ..translate(-25.0, -15.0)
              // تدوير النص بالزاوية المناسبة (بعد التصحيح إن لزم)
              ..rotateZ(middleAngle),
            child: slice.childWidget!,
          ),
        ),
      );
    }

    return sliceWidgets;
  }
}
