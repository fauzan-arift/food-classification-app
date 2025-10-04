import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/image_classification_provider.dart';
import 'image_source_picker.dart';

class ActionButtonsRow extends StatelessWidget {
  const ActionButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageClassificationProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            Expanded(
              child: _ImagePickerButton(
                isEnabled: true,
                onImageSelected: (File imageFile) {
                  provider.classifyImage(imageFile);
                },
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: _AnalyzeButton(
                isEnabled:
                    !provider.isLoading &&
                    provider.isInitialized &&
                    provider.currentImage != null,
                isLoading: provider.isLoading,
                onPressed: () => provider.classifyImage(provider.currentImage!),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ImagePickerButton extends StatelessWidget {
  final bool isEnabled;
  final Function(File) onImageSelected;

  const _ImagePickerButton({
    required this.isEnabled,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isEnabled
            ? LinearGradient(
                colors: [Colors.orange.shade400, Colors.orange.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isEnabled ? null : Colors.grey.shade300,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? () => _showImagePicker(context) : null,
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate,
                  color: isEnabled ? Colors.white : Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pick Image',
                  style: TextStyle(
                    color: isEnabled ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImagePicker(BuildContext context) {
    log('DEBUG: Pick Image button clicked!');
    ImageSourcePicker.show(context, onImageSelected: onImageSelected);
  }
}

class _AnalyzeButton extends StatelessWidget {
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _AnalyzeButton({
    required this.isEnabled,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnabled ? Colors.green.shade600 : Colors.grey.shade300,
          width: 2,
        ),
        color: Colors.white,
      ),
      child: ElevatedButton.icon(
        onPressed: isEnabled ? onPressed : null,
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.green.shade600,
                  ),
                ),
              )
            : Icon(
                Icons.auto_awesome,
                size: 20,
                color: isEnabled ? Colors.green.shade600 : Colors.grey.shade400,
              ),
        label: Text(
          isLoading ? 'Analyzing..' : 'Analyze',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isEnabled ? Colors.green.shade600 : Colors.grey.shade400,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
