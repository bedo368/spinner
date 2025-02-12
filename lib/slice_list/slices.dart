import 'dart:math';
import 'package:flutter/material.dart';
import 'package:spinner/models/circle_clice.dart';

// Function to dynamically generate slice data based on count
List<Map<String, String>> generateSliceData(int sliceCount) {
  return List.generate(sliceCount, (index) {
    return {
      "label": "Slice ${index + 1}",
      "value": "${15 + (index * 5)}%", // Increment percentage dynamically
      "extraData": "Data for Slice ${index + 1}"
    };
  });
}

// Function to dynamically generate slices based on count
List<CircleSlice> generateSlices(int sliceCount) {
  // Define a list of colors (repeated if slice count > colors count)
  final sliceColors = [
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.green,
    Colors.red,
  ];

  final colors = List.generate(sliceCount, (index) {
    return sliceColors[index % sliceColors.length];
  });

  // Generate slice data
  final sliceData = generateSliceData(sliceCount);

  // Generate slices
  return List.generate(sliceCount, (index) {
    final slice = sliceData[index];
    final color = colors[index];

    return CircleSlice(
      activeColor:
          index < sliceColors.length ? sliceColors[index] : Colors.white,
      startAngle:
          -pi / 2 + index * (2 * pi / sliceCount), // Calculate start angle
      sweepAngle: 2 * pi / sliceCount, // Equal sweep for each slice
      defaultColor: color.withOpacity(0.0), // Default slice color
      childWidget: Text(
        slice["value"] as String, // Display slice value
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  });
}
