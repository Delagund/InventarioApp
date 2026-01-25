import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_layout.dart';
import '../../../infrastructure/services/image_picker_service.dart';

class ProductImagePicker extends StatelessWidget {
  final String? imagePath;
  final Function(String?) onImageSelected;

  const ProductImagePicker({
    super.key,
    this.imagePath,
    required this.onImageSelected,
  });

  Future<void> _pickImage() async {
    final newPath = await ImagePickerService.selectAndSaveImage();
    onImageSelected(newPath);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _pickImage,
      child: Center(
        child: Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppLayout.radiusXL),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: imagePath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(AppLayout.radiusXL),
                  child: Image.file(
                    File(imagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, color: Colors.red),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(height: 4),
                    Text("Imagen", style: theme.textTheme.labelSmall),
                  ],
                ),
        ),
      ),
    );
  }
}
