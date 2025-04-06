import 'package:flutter/material.dart';

/// ويدجت لتحديد عدد الشرائح
class SliceCountSelector extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onApply;

  const SliceCountSelector({
    super.key,
    required this.controller,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Row(
        children: [
          const Text('Number of Slices: '),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onApply,
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
