import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:spinner/slice_page/widgets/circle_slices_widget.dart';
import 'package:spinner/slice_list/slices.dart';

/// صفحة مع قائمة تنقل مخصصة لتحديد عدد الشرائح واسم الصورة
class CustomCirclePage extends StatefulWidget {
  const CustomCirclePage({super.key});

  @override
  State<CustomCirclePage> createState() => _CustomCirclePageState();
}

class _CustomCirclePageState extends State<CustomCirclePage> {
  int selectedSlices = 6; // العدد الافتراضي للشرائح
  String selectedImage = 'assets/6.png'; // اسم الصورة الافتراضي

  final List<SliceData> sliceOptions = [
    SliceData(sliceNum: 4, image: "4.png"),
    SliceData(sliceNum: 6, image: "6.png"),
    SliceData(sliceNum: 5, image: "5.png"),
    SliceData(sliceNum: 8, image: "8.png"),
    SliceData(sliceNum: 13, image: "13.png"),
  ]; // خيارات عدد الشرائح
  final TextEditingController angle = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Circle Slices'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            const ListTile(
              title: Text('Select Number of Slices'),
            ),
            ...sliceOptions.map((slices) {
              return ListTile(
                title: Text('${slices.sliceNum} Slices'),
                onTap: () {
                  setState(() {
                    selectedSlices = slices.sliceNum;
                    selectedImage = "assets/${slices.image}";
                  });
                  Navigator.pop(context); // Close the drawer
                },
              );
            }),
            const Divider(),
            const ListTile(
              title: Text('Select Image'),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 300,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Enter angle (in degrees)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: angle,
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            Center(
              child: CircleSlicesWidget(
                imagePath: selectedImage,
                slices: generateSlices(selectedSlices),
                angleInDegrees: double.tryParse(angle.text),
                size: 300, // حجم الدائرة
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SliceData {
  final int sliceNum;
  final String image;
  SliceData({required this.sliceNum, required this.image});
}
