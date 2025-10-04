import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/image_classification_provider.dart';

class ActionButtonsRow extends StatelessWidget {
  final VoidCallback onCameraPressed;

  const ActionButtonsRow({super.key, required this.onCameraPressed});

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageClassificationProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            Expanded(
              child: _CameraButton(
                onPressed: provider.isLoading ? null : onCameraPressed,
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

class _CameraButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _CameraButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.orange.shade600, Colors.deepOrange.shade500],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade300,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(
          Icons.camera_alt_rounded,
          size: 20,
          color: Colors.white,
        ),
        label: const Text(
          'Camera',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
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
