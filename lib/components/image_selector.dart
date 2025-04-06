import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// ويدجت لاختيار وعرض الصورة
class ImageSelector extends StatelessWidget {
  final File? selectedImage;
  final Function(File) onImageSelected;

  const ImageSelector({
    super.key,
    required this.selectedImage,
    required this.onImageSelected,
  });

  /// اختيار صورة من معرض الصور
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      onImageSelected(File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _pickImage,
          child: const Text('Choose Wheel Image'),
        ),

        const SizedBox(height: 10),

        // عرض الصورة المختارة
        if (selectedImage != null)
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              image: DecorationImage(
                image: FileImage(selectedImage!),
                fit: BoxFit.cover,
              ),
            ),
          )
        else
          const Text('No image selected'),
      ],
    );
  }
}
