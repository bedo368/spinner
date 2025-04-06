import 'package:flutter/material.dart';
import 'dart:math' as math;

/// مساعد لإدارة حركة دوران العجلة
class WheelSpinner {
  final AnimationController controller;
  late Animation<double> animation;
  double _currentAngle = 0.0;
  double? _highlightAngle;

  WheelSpinner({required TickerProvider vsync})
      : controller = AnimationController(
          vsync: vsync,
          duration: const Duration(seconds: 2),
        );

  void initialize(
      VoidCallback onAngleUpdate, VoidCallback onAnimationComplete) {
    // استمع إلى تغييرات قيمة الأنيميشن
    controller.addListener(() {
      updateCurrentAngle();
      onAngleUpdate();
    });

    // استمع إلى حالة انتهاء الأنيميشن
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onAnimationComplete();
      }
    });
  }

  void dispose() {
    controller.dispose();
  }

  /// بدء حركة الدوران إلى الزاوية المستهدفة
  void spinToAngle({required double targetAngleDegrees}) {
    // نحول من درجات إلى راديان
    final targetRad = targetAngleDegrees * math.pi / 180;

    // عدم إضاءة شريحة أثناء الحركة
    _highlightAngle = null;

    // إعداد التحريك من الزاوية الحالية إلى المستهدفة
    animation = Tween<double>(
      begin: _currentAngle,
      end: targetRad,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutExpo, // منحنى تباطؤ قوي
      ),
    );

    // بدء الحركة من الصفر
    controller.forward(from: 0.0);
  }

  /// استدعاء هذه الدالة من الاستماع إلى تغيير قيمة الأنيميشن
  void updateCurrentAngle() {
    _currentAngle = animation.value;
  }

  /// استدعاء هذه الدالة عند انتهاء الأنيميشن
  void setHighlightAngle(double angleDegrees) {
    _highlightAngle = 360 - angleDegrees; // نحسب بعكس اتجاه المؤشر
  }

  // خصائص للقراءة
  double get currentAngle => _currentAngle;
  double? get highlightAngle => _highlightAngle;
}
