// lib/models/circle_slice.dart

import 'package:flutter/material.dart';

/// فئة بيانات تمثل شريحة واحدة في الدائرة
class CircleSlice {
  final double startAngle; // زاوية البداية (بالراديان)
  final double sweepAngle; // زاوية الاتساع (بالراديان)
  final Color defaultColor; // لون الشريحة الافتراضي
  final Color activeColor;

  /// ويدجت اختياري لعرضه فوق الشريحة (نص/أيقونة/... إلخ)
  final Widget? childWidget;

  CircleSlice({
    required this.startAngle,
    required this.sweepAngle,
    required this.defaultColor,
    required this.activeColor,
    this.childWidget,
  });
}
