import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:spinner/slice_list/slices.dart';
import 'package:spinner/slice_page/widgets/circle_slices_widget.dart';
import 'package:image_picker/image_picker.dart';

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

/// صفحة رئيسية مع إمكانية اختيار صورة مخصصة وعدد الشرائح + دائرة بشرائح + مؤشر (سهم) فوق الدائرة
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
  // ملف الصورة المختارة من المستخدم
  File? userImage;
  // التحكم في عدد الشرائح
  final TextEditingController _slicesController =
      TextEditingController(text: '6');

  // للتحكم في زاوية الدوران - نبدأ من 1 وليس 0
  double _selectedAngle = 1.0;

  // للتحكم في حركة دوران الدائرة
  late AnimationController _circleController;
  late Animation<double> _circleAnimation;

  // زاوية دوران الدائرة الحالية (بالراديان)
  double _currentCircleAngle = 0.0;

  // الزاوية (بالدرجات) التي نُضيئها بعد انتهاء الدوران. null = لا إضاءة
  double? _highlightAngleDeg;

  @override
  void initState() {
    super.initState();
    // نغير مدة اللف إلى 2 ثانية
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // عند تغير قيمة الأنيميشن، نغيّر زاوية الدائرة
    _circleController.addListener(() {
      setState(() {
        _currentCircleAngle = _circleAnimation.value;
      });
    });

    // عند انتهاء الأنيميشن، نُفعِّل إضاءة الشريحة
    _circleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          // نستخدم الزاوية كما هي لأن الدائرة تدور الآن مع اتجاه المؤشر (عكس عقارب الساعة)
          _highlightAngleDeg = _selectedAngle;
        });
      }
    });
  }

  @override
  void dispose() {
    _circleController.dispose();
    _slicesController.dispose();
    super.dispose();
  }

  /// بدء دوران الدائرة
  void _startCircleSpin() {
    // نحولها إلى راديان
    final targetRad = _selectedAngle * math.pi / 180;

    // نعطّل إضاءة الشريحة أثناء الحركة
    _highlightAngleDeg = null;

    // Tween من زاويتنا الحالية إلى الهدف النهائي
    // نستخدم قيمة سالبة للـ end لجعل الدوران عكس اتجاه عقارب الساعة
    _circleAnimation = Tween<double>(
      begin: _currentCircleAngle, // نبدأ من الزاوية الحالية
      end: -targetRad, // قيمة سالبة للدوران عكس عقارب الساعة
    ).animate(
      CurvedAnimation(
        parent: _circleController,
        curve: Curves.easeOutExpo, // منحنى تباطؤ قوي
      ),
    );

    // بدء الحركة من الصفر
    _circleController.forward(from: 0.0);
  }

  /// اختيار صورة من المعرض
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        userImage = File(image.path);
      });
    }
  }

  /// تحديث عدد الشرائح
  void _updateSlices() {
    final int? slices = int.tryParse(_slicesController.text);
    if (slices != null && slices > 1) {
      setState(() {
        selectedSlices = slices;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid number (greater than 1)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Circle Slices'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // اختيار الصورة
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Choose Wheel Image'),
              ),

              const SizedBox(height: 10),

              // عرض الصورة المختارة
              if (userImage != null)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    image: DecorationImage(
                      image: FileImage(userImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                const Text('No image selected'),

              const SizedBox(height: 20),

              // تحديد عدد الشرائح
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Row(
                  children: [
                    const Text('Number of Slices: '),
                    Expanded(
                      child: TextField(
                        controller: _slicesController,
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
                      onPressed: _updateSlices,
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // سلايدر لاختيار الزاوية
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    const Text('Angle: '),
                    Expanded(
                      child: Slider(
                        value: _selectedAngle,
                        min: 1,
                        max: 360,
                        divisions: 36,
                        label: _selectedAngle.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            _selectedAngle = value;
                            // بدء دوران الدائرة عند تحريك السلايدر
                            _startCircleSpin();
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
                    // الدائرة والشرائح - الآن تدور
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..rotateZ(_currentCircleAngle),
                      child: CircleSlicesWidget(
                        imagePath: userImage != null ? null : selectedImage,
                        imageFile: userImage,
                        slices: generateSlices(selectedSlices),
                        angleInDegrees: null,
                        size: 300,
                      ),
                    ),
                    // المؤشر (السهم الأحمر) - ثابت أعلى الدائرة
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
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
