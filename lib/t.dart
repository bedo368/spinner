import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// The root of your Flutter app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gear Spinner Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SpinnerPage(),
    );
  }
}

/// A page that lets you pick how many slices to show.
class SpinnerPage extends StatefulWidget {
  const SpinnerPage({Key? key}) : super(key: key);

  @override
  State<SpinnerPage> createState() => _SpinnerPageState();
}

class _SpinnerPageState extends State<SpinnerPage> {
  /// Default to 8 slices
  String _sliceCountText = "8";

  /// Returns the slice count (integer), clamped to [1..50].
  int get sliceCount {
    final parsed = int.tryParse(_sliceCountText) ?? 1;
    return parsed.clamp(1, 50);
  }

  /// Generate random Colors (fully opaque) for the slices.
  List<Color> _generateRandomColors(int count) {
    final rand = Random();
    return List.generate(count, (_) {
      return Color.fromARGB(
        255,
        rand.nextInt(256),
        rand.nextInt(256),
        rand.nextInt(256),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = _generateRandomColors(sliceCount);

    return Scaffold(
      appBar: AppBar(title: const Text("Gear Spinner Example")),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Text field to pick how many slices
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: const InputDecoration(labelText: "Number of slices"),
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() => _sliceCountText = value),
              controller: TextEditingController(text: _sliceCountText),
            ),
          ),
          const SizedBox(height: 16),

          // The spinner
          Expanded(
            child: Center(
              child: CustomPaint(
                size: const Size(320, 320),
                painter: GearSpinnerPainter(
                  sliceCount: sliceCount,
                  sliceColors: colors,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter يرسم السبّينر بالشكل الأقرب للصورة:
/// 1) دائرة خارجية فيها شرائح ملوّنة.
/// 2) ترس (Gear) أسود في المنتصف.
/// 3) دائرة بيضاء فوق الترس لتظهر فقط أطراف الترس.
/// 4) في كل شريحة، دائرة ملوّنة فوقها دائرة بيضاء أصغر.
class GearSpinnerPainter extends CustomPainter {
  final int sliceCount;
  final List<Color> sliceColors;

  GearSpinnerPainter({
    required this.sliceCount,
    required this.sliceColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (sliceCount == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.shortestSide / 2;

    // 1) رسم خلفية دائرية بيضاء (كإطار خارجي)
    final outerCirclePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, outerRadius, outerCirclePaint);

    // 2) رسم الشرائح الملوّنة
    final sweep = 2 * pi / sliceCount;
    final wedgeRect = Rect.fromCircle(center: center, radius: outerRadius);
    final paintSlice = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < sliceCount; i++) {
      final startAngle = -pi / 2 + i * sweep;
      paintSlice.color = sliceColors[i % sliceColors.length];
      canvas.drawArc(wedgeRect, startAngle, sweep, true, paintSlice);
    }

    // 3) رسم الترس (Gear) بالأسود في المنتصف
    final gearOuter = outerRadius * 0.3; // نصف القطر الخارجي للترس
    final gearInner = gearOuter * 0.4; // نصف القطر الداخلي للسنّة

    final gearPath = _buildGearPath(
      center: center,
      sliceCount: sliceCount,
      outerRadius: gearOuter,
      innerRadius: gearInner,
    );

    final gearPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawPath(gearPath, gearPaint);

    // 4) دائرة بيضاء كبيرة تغطّي أغلب الترس، تبقي فقط أطراف الترس ظاهرة
    final centerCircleRadius = gearOuter * 0.4;
    final centerCirclePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, centerCircleRadius, centerCirclePaint);

    // 5) دوائر "بارزة" في كل شريحة + دائرة بيضاء أصغر فوقها
    //    شبيهة بالأقراص في الصورة
    final diskOuterRadius = outerRadius * 0.13; // الدائرة الملوّنة
    final diskInnerRadius = diskOuterRadius * 0.9; // الدائرة البيضاء الأصغر

    for (int i = 0; i < sliceCount; i++) {
      final midAngle = -pi / 2 + i * sweep + sweep / 2;

      // موضع مركز الدائرة الملوّنة بالنسبة للشريحة
      final circleCenterDist = outerRadius * 0.8;
      final circleCenter = Offset(
        center.dx + circleCenterDist * cos(midAngle),
        center.dy + circleCenterDist * sin(midAngle),
      );

      // الدائرة الملوّنة
      final circlePaint = Paint()..color = sliceColors[i % sliceColors.length];
      canvas.drawCircle(circleCenter, diskOuterRadius, circlePaint);

      // الدائرة البيضاء الأصغر
      canvas.drawCircle(circleCenter, diskInnerRadius, centerCirclePaint);
    }
  }

  /// يبني مسار (Path) يمثّل "ترس" (Gear) بعدد أسنان يساوي عدد الشرائح.
  Path _buildGearPath({
    required Offset center,
    required int sliceCount,
    required double outerRadius,
    required double innerRadius,
  }) {
    final path = Path();
    if (sliceCount < 2) {
      // لو شريحة واحدة فقط، ارسم دائرة
      path.addOval(Rect.fromCircle(center: center, radius: outerRadius));
      return path;
    }

    final step = 2 * pi / sliceCount;
    double angle = -pi / 2;

    // ابدأ من أول سنّة
    path.moveTo(
      center.dx + outerRadius * cos(angle),
      center.dy + outerRadius * sin(angle),
    );

    for (int i = 0; i < sliceCount; i++) {
      final midAngle = angle + step / 2;
      // حافة داخلية للسنّة
      final inX = center.dx + innerRadius * cos(midAngle);
      final inY = center.dy + innerRadius * sin(midAngle);
      path.lineTo(inX, inY);

      angle += step;
      // حافة خارجية للسنّة
      final outX = center.dx + outerRadius * cos(angle);
      final outY = center.dy + outerRadius * sin(angle);
      path.lineTo(outX, outY);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
