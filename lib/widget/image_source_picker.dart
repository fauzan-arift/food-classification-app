import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_cropper_service.dart';

class ImageSourcePicker extends StatelessWidget {
  final Function(File imageFile)? onImageSelected;

  const ImageSourcePicker({super.key, this.onImageSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Text(
              'Select Image Source',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSourceButton(
                  context: context,
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  source: ImageSource.camera,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSourceButton(
                  context: context,
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  source: ImageSource.gallery,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required ImageSource source,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _pickImage(context, source),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickImage(BuildContext context, ImageSource source) async {
    log('DEBUG: _pickImage called with source: $source');
    Navigator.pop(context);

    final imageCropperService = ImageCropperService();
    final croppedImage = await imageCropperService.pickAndCropImage(source);

    log('DEBUG: Cropped image result: ${croppedImage?.path}');
    if (croppedImage != null && onImageSelected != null) {
      onImageSelected!(croppedImage);
    }
  }

  static void show(BuildContext context, {Function(File)? onImageSelected}) {
    log('DEBUG: ImageSourcePicker.show called!');
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ImageSourcePicker(onImageSelected: onImageSelected),
    );
  }
}
