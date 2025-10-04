import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import '../services/image_classification_service.dart';

enum ClassificationState { initial, loading, loaded, error }

class ImageClassificationProvider extends ChangeNotifier {
  final ImageClassificationService _classificationService =
      ImageClassificationService();

  ClassificationState _state = ClassificationState.initial;
  List<Map<String, dynamic>> _classifications = [];
  String _error = '';
  File? _currentImage;
  bool _isInitialized = false;
  bool _showCamera = false;
  bool _isClassifying = false;

  // Getters
  ClassificationState get state => _state;
  List<Map<String, dynamic>> get classifications => _classifications;
  String get error => _error;
  File? get currentImage => _currentImage;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _state == ClassificationState.loading;
  bool get showCamera => _showCamera;

  Future<void> initialize() async {
    try {
      log('Initializing ImageClassificationProvider...');
      await _classificationService.initialize();
      _isInitialized = true;
      log('ImageClassificationProvider initialized successfully');
    } catch (e) {
      _error = 'Failed to initialize ML model: $e';
      _state = ClassificationState.error;
      log('Error initializing provider: $e');
      notifyListeners();
    }
  }

  Future<void> classifyImage(File imageFile) async {
    if (_isClassifying) {
      log('Classification already in progress, ignoring new request');
      return;
    }

    if (!_isInitialized) {
      await initialize();
    }

    _isClassifying = true;
    _state = ClassificationState.loading;
    _currentImage = imageFile;
    _error = '';
    notifyListeners();

    try {
      log('Starting image classification with isolate...');

      final results = await _classificationService.classifyImage(imageFile);

      if (_isClassifying) {
        _classifications = results;
        _state = ClassificationState.loaded;

        log(
          'Classification completed successfully. Found ${results.length} results',
        );
      }
    } catch (e) {
      if (_isClassifying) {
        _error = 'Classification failed: $e';
        _state = ClassificationState.error;
        _classifications = [];
        log('Classification error: $e');
      }
    } finally {
      _isClassifying = false;
      notifyListeners();
    }
  }

  void clearResults() {
    _classifications = [];
    _currentImage = null;
    _error = '';
    _state = ClassificationState.initial;
    _isClassifying = false; // Cancel any ongoing classification
    notifyListeners();
  }

  void toggleCamera() {
    _showCamera = !_showCamera;
    notifyListeners();
  }

  void hideCamera() {
    _showCamera = false;
    notifyListeners();
  }

  Map<String, dynamic>? get topResult {
    if (_classifications.isEmpty) return null;
    return _classifications.first;
  }

  double get topConfidence {
    final top = topResult;
    if (top == null) return 0.0;
    return (top['confidence'] as double) * 100;
  }

  String get topLabel {
    final top = topResult;
    if (top == null) return 'Unknown';
    return top['label'] as String;
  }

  @override
  void dispose() {
    _classificationService.dispose();
    super.dispose();
  }
}
