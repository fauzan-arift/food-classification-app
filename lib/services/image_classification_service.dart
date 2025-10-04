import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'isolate_inference.dart';

class ImageClassificationService {
  static const String _modelPath = 'assets/models/1.tflite';
  static const String _labelPath = 'assets/models/labels.txt';

  late Interpreter _interpreter;
  late List<String> _labels;
  late IsolateInference _isolateInference;

  bool _isModelLoaded = false;

  ImageClassificationService._();
  static final ImageClassificationService _instance =
      ImageClassificationService._();
  factory ImageClassificationService() => _instance;

  bool get isModelLoaded => _isModelLoaded;

  Future<void> initialize() async {
    try {
      log('Loading TensorFlow Lite model...');

      _interpreter = await Interpreter.fromAsset(_modelPath);
      log('Model loaded successfully');

      await _loadLabels();
      log('Labels loaded: ${_labels.length} categories');

      _isolateInference = IsolateInference(_interpreter);

      _isModelLoaded = true;
      log('Image classification service initialized successfully');
    } catch (e) {
      log('Error initializing image classification service: $e');
      throw Exception('Failed to initialize model: $e');
    }
  }

  Future<void> _loadLabels() async {
    try {
      final String labelData = await rootBundle.loadString(_labelPath);
      _labels = labelData
          .split('\n')
          .where((label) => label.isNotEmpty)
          .toList();
    } catch (e) {
      log('Error loading labels: $e');
      _labels = ['Unknown']; // Fallback
    }
  }

  Future<List<Map<String, dynamic>>> classifyImage(File imageFile) async {
    if (!_isModelLoaded) {
      throw Exception('Model not initialized');
    }

    try {
      log('Starting image classification...');

      // Process image
      final processedImage = await _preprocessImage(imageFile);

      // Run inference
      final results = await _isolateInference.runInference(processedImage);

      // Process results
      final classifications = _processResults(results);

      log('Classification completed. Found ${classifications.length} results');
      return classifications;
    } catch (e) {
      log('Error during classification: $e');
      throw Exception('Classification failed: $e');
    }
  }

  Future<Uint8List> _preprocessImage(File imageFile) async {
    try {
      // Use decodeImageFile for static images as per specification
      final image = await img.decodeImageFile(imageFile.path);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize image to actual model input size (192x192 based on model shape)
      final resized = img.copyResize(image, width: 192, height: 192);

      // Convert to Uint8List as required by the model (uint8 data type)
      final input = Uint8List(1 * 192 * 192 * 3);
      var pixelIndex = 0;

      for (int y = 0; y < 192; y++) {
        for (int x = 0; x < 192; x++) {
          final pixel = resized.getPixel(x, y);

          // Extract RGB channels as uint8 values (0-255 range)
          input[pixelIndex++] = pixel.r.toInt();
          input[pixelIndex++] = pixel.g.toInt();
          input[pixelIndex++] = pixel.b.toInt();
        }
      }

      return input;
    } catch (e) {
      log('Error preprocessing image: $e');
      throw Exception('Image preprocessing failed: $e');
    }
  }

  List<Map<String, dynamic>> _processResults(List<dynamic> results) {
    try {
      log('Processing results: ${results.runtimeType}');

      // Handle the output from isolate
      List<double> probabilities;
      if (results is List<List<List<double>>>) {
        probabilities = results[0][0];
      } else if (results is List<List<double>>) {
        probabilities = results[0];
      } else if (results is List<double>) {
        probabilities = results;
      } else {
        // Try to convert dynamic list to double list
        try {
          probabilities = results.map((e) => (e as num).toDouble()).toList();
        } catch (e) {
          log('Unexpected results type: ${results.runtimeType}');
          return [];
        }
      }

      log('Probabilities length: ${probabilities.length}');
      log('Labels length: ${_labels.length}');

      // Ensure we don't exceed bounds
      if (probabilities.isEmpty || _labels.isEmpty) {
        log('Empty probabilities or labels');
        return [];
      }

      // Create list of results with labels and confidences
      final classifications = <Map<String, dynamic>>[];

      // Process probabilities for 2023 food dishes as per specification
      // Skip background class (index 0) and process only food items
      for (
        int i = 1;
        i < probabilities.length && (i - 1) < (_labels.length - 1);
        i++
      ) {
        // Skip background class at index 0, map to food labels
        if (i < _labels.length) {
          classifications.add({
            'label':
                _labels[i], // Use original index for label (includes background)
            'confidence': probabilities[i],
            'index': i,
          });
        }
      }

      // Sort by confidence (highest first)
      classifications.sort(
        (a, b) =>
            (b['confidence'] as double).compareTo(a['confidence'] as double),
      );

      // Return top 5 results
      return classifications.take(5).toList();
    } catch (e) {
      log('Error processing results: $e');
      return [
        {'label': 'Unknown', 'confidence': 0.0, 'index': -1},
      ];
    }
  }

  void dispose() {
    try {
      _interpreter.close();
      _isolateInference.close();
      _isModelLoaded = false;
      log('Image classification service disposed');
    } catch (e) {
      log('Error disposing service: $e');
    }
  }
}
