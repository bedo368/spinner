import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:spinner/slice_list/slices.dart';
import 'package:spinner/slice_page/widgets/circle_slices_widget.dart';

void main() {
  runApp(const MyApp());
}

/// التطبيق الرئيسي
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Circle Slices Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CustomCirclePage(),
    );
  }
}

/// صفحة رئيسية مع Drawer لاختيار عدد الشرائح والصورة + دائرة بشرائح + مؤشر (سهم) فوق الدائرة
class CustomCirclePage extends StatefulWidget {
  const CustomCirclePage({super.key});

  @override
  State<CustomCirclePage> createState() => _CustomCirclePageState();
}

class _CustomCirclePageState extends State<CustomCirclePage>
    with SingleTickerProviderStateMixin {
  // عدد الشرائح الافتراضي
  int selectedSlices = 6;
  // الصورة الافتراضية
  String selectedImage = 'assets/6.png';

  // خيارات الشرائح والصور في الدّرّاور
  final List<SliceData> sliceOptions = [
    SliceData(sliceNum: 4, image: '4.png'),
    SliceData(sliceNum: 6, image: '6.png'),
    SliceData(sliceNum: 5, image: '5.png'),
    SliceData(sliceNum: 8, image: '8.png'),
    SliceData(sliceNum: 13, image: '13.png'),
  ];

  // للتحكم في زاوية المؤشر
  double _selectedAngle = 0.0;

  // للتحكم في حركة دوران المؤشر (السهم)
  late AnimationController _pointerController;
  late Animation<double> _pointerAnimation;

  // زاوية المؤشر الحالية (بالراديان). نبدأ من أعلى الدائرة = -pi/2
  double _currentPointerAngle = -math.pi / 2;

  // الزاوية (بالدرجات) التي نُضيئها بعد انتهاء الدوران. null = لا إضاءة
  double? _highlightAngleDeg;

  @override
  void initState() {
    super.initState();
    // نجعل مدة اللف 9 ثواني
    _pointerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    );

    // عند تغير قيمة الأنيميشن، نغيّر زاوية المؤشر
    _pointerController.addListener(() {
      setState(() {
        _currentPointerAngle = _pointerAnimation.value;
      });
    });

    // عند انتهاء الأنيميشن، نُفعِّل إضاءة الشريحة
    _pointerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _highlightAngleDeg = _selectedAngle;
        });
      }
    });
  }

  @override
  void dispose() {
    _pointerController.dispose();
    super.dispose();
  }

  /// بدء دوران المؤشر
  void _startPointerSpin() {
    // Reset the spinner to start from the top each time.
    _currentPointerAngle = -math.pi / 2;

    // نحولها إلى راديان مع طرح pi/2 لجعل 0 في أعلى الدائرة
    final targetRad = (_selectedAngle * math.pi / 180) - math.pi / 2;

    // نضيف 7 لفّات إضافية (7 * 2π)
    const extraSpins = 7 * 2 * math.pi;
    final finalTarget = targetRad + extraSpins;

    // نعطّل إضاءة الشريحة أثناء الحركة
    _highlightAngleDeg = null;

    // Tween من زاويتنا الحالية إلى الهدف النهائي
    _pointerAnimation = Tween<double>(
      begin: _currentPointerAngle,
      end: finalTarget,
    ).animate(
      CurvedAnimation(
        parent: _pointerController,
        curve: Curves.easeOutExpo, // منحنى تباطؤ قوي
      ),
    );

    // بدء الحركة من الصفر
    _pointerController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Circle Slices'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Settings',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            const ListTile(title: Text('Select Number of Slices')),
            ...sliceOptions.map((slices) {
              return ListTile(
                title: Text('${slices.sliceNum} Slices'),
                onTap: () {
                  setState(() {
                    selectedSlices = slices.sliceNum;
                    selectedImage = 'assets/${slices.image}';
                  });
                  Navigator.pop(context);
                },
              );
            }),
            const Divider(),
            const ListTile(title: Text('Select Image')),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // سلايدر لاختيار الزاوية
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  const Text('Angle: '),
                  Expanded(
                    child: Slider(
                      value: _selectedAngle,
                      min: 0,
                      max: 360,
                      divisions: 36,
                      label: _selectedAngle.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _selectedAngle = value;
                          // Automatically start spin when slider moves
                          _startPointerSpin();
                        });
                      },
                    ),
                  ),
                  Text('${_selectedAngle.round()}°'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // الدائرة + المؤشر
            SizedBox(
              width: 300,
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // الدائرة والشرائح
                  CircleSlicesWidget(
                    imagePath: selectedImage,
                    slices: generateSlices(selectedSlices),
                    angleInDegrees: _highlightAngleDeg,
                    size: 300,
                  ),
                  // المؤشر (السهم الأحمر) أعلى الدائرة
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      // ندور المؤشر بالزاوية الحالية
                      ..rotateZ((math.pi / 2) + _currentPointerAngle)
                      // نرفعه لأعلى بمقدار نصف قطر الدائرة (150)
                      ..translate(0.0, -150.0),
                    child: const Icon(
                      Icons.arrow_drop_down,
                      size: 40,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper classes and functions (keep the original implementations)
class SliceData {
  final int sliceNum;
  final String image;
  SliceData({required this.sliceNum, required this.image});
}

class CircleSlice {
  final double startAngle;
  final double sweepAngle;
  final Color defaultColor;
  final Color activeColor;
  final Widget? childWidget;

  CircleSlice({
    required this.startAngle,
    required this.sweepAngle,
    required this.defaultColor,
    required this.activeColor,
    this.childWidget,
  });
}
