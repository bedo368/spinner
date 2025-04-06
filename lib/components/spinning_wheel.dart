import 'dart:io';
import 'package:flutter/material.dart';
import 'package:spinner/slice_page/widgets/circle_slices_widget.dart';
import 'package:spinner/slice_list/slices.dart';

/// ويدجت لعرض العجلة مع السهم
class SpinningWheel extends StatelessWidget {
  final double currentAngle;
  final double? highlightAngle;
  final String? defaultImagePath;
  final File? userImage;
  final int sliceCount;
  final double size;

  const SpinningWheel({
    super.key,
    required this.currentAngle,
    this.highlightAngle,
    this.defaultImagePath,
    this.userImage,
    required this.sliceCount,
    this.size = 300,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // العجلة التي تدور
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateZ(currentAngle),
            child: CircleSlicesWidget(
              imagePath: userImage != null ? null : defaultImagePath,
              imageFile: userImage,
              slices: generateSlices(sliceCount),
              angleInDegrees: highlightAngle,
              size: size,
            ),
          ),
          // المؤشر (السهم الأحمر) في أعلى الدائرة
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(0.0, -size / 2), // في أعلى الدائرة
            child: const Icon(
              Icons.arrow_drop_down,
              size: 40,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
