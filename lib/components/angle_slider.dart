import 'package:flutter/material.dart';

/// ويدجت لاختيار الزاوية باستخدام سلايدر
class AngleSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const AngleSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          const Text('Angle: '),
          Expanded(
            child: Slider(
              value: value,
              min: 1,
              max: 360,
              divisions: 36,
              label: value.round().toString(),
              onChanged: onChanged,
            ),
          ),
          Text('${value.round()}°'),
        ],
      ),
    );
  }
}
