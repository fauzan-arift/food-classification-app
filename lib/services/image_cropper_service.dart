import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageCropperService {
  ImageCropperService._();
  static final ImageCropperService _instance = ImageCropperService._();
  factory ImageCropperService() => _instance;

  Future<File?> pickAndCropImage(ImageSource imageType) async {
    File? tempImage;
    try {
      final photo = await ImagePicker().pickImage(
        source: imageType,
        imageQuality: 100,
      );

      if (photo == null) return null;

      tempImage = File(photo.path);
      tempImage = await _cropImage(imageFile: tempImage);

      return tempImage;
    } catch (error) {
      log('Error picking and cropping image: $error');
      return null;
    }
  }

  Future<File?> _cropImage({required File imageFile}) async {
    try {
      CroppedFile? croppedImg = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Food Image',
            toolbarColor: const Color(0xFFFF9800),
            toolbarWidgetColor: const Color(0xFFFFFFFF),
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: 'Crop Food Image',
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );

      if (croppedImg == null) {
        return null;
      } else {
        return File(croppedImg.path);
      }
    } catch (e) {
      log('Error cropping image: $e');
      return null;
    }
  }
}
