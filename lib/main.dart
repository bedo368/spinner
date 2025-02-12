import 'dart:math' as math;
import 'package:flutter/material.dart';

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

  // حقل إدخال للزاوية
  final TextEditingController angleController = TextEditingController();

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

    // عند انتهاء الأنيميشن، نُفعِّل إضاءة الشريحة
    _pointerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        final enteredAngle = double.tryParse(angleController.text) ?? 0.0;
        setState(() {
          _highlightAngleDeg = enteredAngle.clamp(0, 360);
        });
      }
    });
  }

  @override
  void dispose() {
    _pointerController.dispose();
    super.dispose();
  }

  /// عند الضغط على زر Spin!
  void _startPointerSpin() {
    // نقرأ الزاوية المدخلة
    final enteredAngleDeg = double.tryParse(angleController.text) ?? 0.0;
    final clampedDeg = enteredAngleDeg.clamp(0, 360);

    // نحولها إلى راديان مع طرح pi/2 لجعل 0 في أعلى الدائرة
    final targetRad = (clampedDeg * math.pi / 180) - math.pi / 2;

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
            // إدخال الزاوية
            SizedBox(
              width: 300,
              child: TextField(
                controller: angleController,
                decoration: const InputDecoration(
                  labelText: 'Enter angle (0..360)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _startPointerSpin,
              child: const Text('Spin!'),
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

/// يمثل خيار عدد الشرائح + اسم الصورة
class SliceData {
  final int sliceNum;
  final String image;
  SliceData({required this.sliceNum, required this.image});
}

/// فئة بيانات للشريحة
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

/// رسام الشرائح
class CircleSlicesPainter extends CustomPainter {
  final List<CircleSlice> slices;
  final double? highlightAngle;
  final double blinkFactor;

  CircleSlicesPainter({
    required this.slices,
    this.highlightAngle,
    this.blinkFactor = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (final slice in slices) {
      paint.color = slice.defaultColor;

      // إن كانت highlightAngle ضمن هذه الشريحة
      if (highlightAngle != null && _angleInSlice(highlightAngle!, slice)) {
        paint.color =
            Color.lerp(slice.defaultColor, slice.activeColor, blinkFactor) ??
                slice.activeColor;
      }

      // رسم الشريحة
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        slice.startAngle,
        slice.sweepAngle,
        true,
        paint,
      );
    }
  }

  bool _angleInSlice(double angle, CircleSlice slice) {
    const epsilon = 0.0001;
    final endAngle = slice.startAngle + slice.sweepAngle - epsilon;
    final a = _normalizeAngle(angle);
    final s = _normalizeAngle(slice.startAngle);
    final e = _normalizeAngle(endAngle);

    if (s < e) {
      return a >= s && a <= e;
    } else {
      return (a >= s && a <= 2 * math.pi) || (a >= 0 && a <= e);
    }
  }

  double _normalizeAngle(double angle) {
    final twoPi = 2 * math.pi;
    return (angle % twoPi + twoPi) % twoPi;
  }

  @override
  bool shouldRepaint(covariant CircleSlicesPainter oldDelegate) {
    return oldDelegate.slices != slices ||
        oldDelegate.highlightAngle != highlightAngle ||
        oldDelegate.blinkFactor != blinkFactor;
  }
}

/// ويدجت لرسم دائرة بخلفية صورة + شرائح
class CircleSlicesWidget extends StatefulWidget {
  final String imagePath;
  final List<CircleSlice> slices;
  final double? angleInDegrees;
  final double size;

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
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    // أنيميشن تكراري للوميض
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _blinkAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_blinkController);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  double? get _highlightAngleInRadians {
    if (widget.angleInDegrees == null) return null;
    final deg = widget.angleInDegrees!.clamp(0, 360);
    final rad = deg * math.pi / 180;
    return rad - math.pi / 2;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              widget.imagePath,
              fit: BoxFit.cover,
            ),
          ),
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
          ..._buildSliceWidgets(),
        ],
      ),
    );
  }

  List<Widget> _buildSliceWidgets() {
    final list = <Widget>[];
    final radius = widget.size / 2;
    final center = Offset(radius, radius);

    for (final slice in widget.slices) {
      if (slice.childWidget == null) continue;

      double midAngle = slice.startAngle + slice.sweepAngle / 2;
      final r = radius * 0.65;
      final dx = center.dx + r * math.cos(midAngle);
      final dy = center.dy + r * math.sin(midAngle);

      double normAngle = midAngle % (2 * math.pi);
      if (normAngle < 0) normAngle += 2 * math.pi;
      if (normAngle > math.pi / 2 && normAngle < 3 * math.pi / 2) {
        midAngle += math.pi;
      }

      list.add(
        Positioned(
          left: dx,
          top: dy,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(-25.0, -15.0)
              ..rotateZ(midAngle),
            child: slice.childWidget!,
          ),
        ),
      );
    }
    return list;
  }
}

/// دوال مساعدة لتوليد الشرائح وبياناتها
List<CircleSlice> generateSlices(int sliceCount) {
  final sliceColors = [
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.green,
    Colors.red,
  ];
  final colors = List.generate(sliceCount, (i) {
    return sliceColors[i % sliceColors.length];
  });
  final sliceData = generateSliceData(sliceCount);

  return List.generate(sliceCount, (i) {
    final data = sliceData[i];
    final color = colors[i];

    return CircleSlice(
      startAngle: -math.pi / 2 + i * (2 * math.pi / sliceCount),
      sweepAngle: 2 * math.pi / sliceCount,
      defaultColor: color.withOpacity(0.0),
      activeColor: color,
      childWidget: Text(
        data['value'] ?? '',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  });
}

List<Map<String, String>> generateSliceData(int sliceCount) {
  return List.generate(sliceCount, (i) {
    return {
      'label': 'Slice ${i + 1}',
      'value': '${(10 + i * 5)}%',
    };
  });
}
