import 'dart:developer';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';

class IsolateInference {
  static const String _debugName = "TFLITE_INFERENCE";
  final Interpreter _interpreter;
  late SendPort _sendPort;
  late Isolate _isolate;
  late ReceivePort _receivePort;
  bool _isReady = false;

  IsolateInference(this._interpreter);

  bool get isReady => _isReady;

  Future<void> start() async {
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn<SendPort>(
      entryPoint,
      _receivePort.sendPort,
      debugName: _debugName,
    );
    _sendPort = await _receivePort.first;
    _isReady = true;
  }

  Future<List<dynamic>> runInference(Uint8List inputData) async {
    try {
      if (!_isReady) {
        await start();
      }

      ReceivePort responsePort = ReceivePort();
      _sendPort.send([responsePort.sendPort, inputData, _interpreter.address]);

      // Add timeout to prevent hanging
      final result = await responsePort.first.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          log('Isolate inference timed out');
          return <double>[];
        },
      );

      return result;
    } catch (e) {
      log('Error in runInference: $e');
      return <double>[];
    }
  }

  static void entryPoint(SendPort sendPort) async {
    ReceivePort port = ReceivePort();
    sendPort.send(port.sendPort);

    await for (var message in port) {
      if (message is List && message.length == 3) {
        SendPort responsePort = message[0];
        Uint8List inputData = message[1];
        int interpreterAddress = message[2];

        try {
          // Create interpreter from address
          Interpreter interpreter = Interpreter.fromAddress(interpreterAddress);

          log('Input data length: ${inputData.length}');
          log('Input data type: ${inputData.runtimeType}');

          // Prepare input and output for MobileNet V1 food classifier
          // Input: 192x192 RGB images as uint8 (0-255 range)
          var input = inputData.reshape([1, 192, 192, 3]);

          // Check model input/output details
          log('Model input shape: ${interpreter.getInputTensor(0).shape}');
          log('Model input type: ${interpreter.getInputTensor(0).type}');
          log('Model output shape: ${interpreter.getOutputTensor(0).shape}');
          log('Model output type: ${interpreter.getOutputTensor(0).type}');

          // Output: probability vector based on actual model output shape
          var outputTensor = interpreter.getOutputTensor(0);
          var outputShape = outputTensor.shape;

          // Create output buffer using TensorFlow Lite's allocateTensors approach
          log('Output tensor shape: ${outputTensor.shape}');
          log('Output tensor type: ${outputTensor.type}');

          // Create proper output buffer for uint8
          var outputBuffer = List.filled(outputShape[1], 0);
          var output = [outputBuffer];

          log('Prepared output buffer length: ${outputBuffer.length}');

          // Run inference
          interpreter.run(input, output);

          log('Inference completed');
          log('Output buffer type: ${output[0].runtimeType}');
          log('Output buffer length: ${output[0].length}');

          // Convert output to double list (normalize uint8 to 0-1 range)
          List<double> doubleOutput = output[0]
              .map<double>((e) => e.toDouble() / 255.0)
              .toList();

          log(
            'Converted to probabilities, first 5: ${doubleOutput.take(5).toList()}',
          );

          // Send the converted output
          responsePort.send(doubleOutput);
        } catch (e) {
          log('Isolate inference error: $e');
          responsePort.send([]);
        }
      }
    }
  }

  void close() {
    if (_isReady) {
      _receivePort.close();
      _isolate.kill(priority: Isolate.immediate);
      _isReady = false;
    }
  }
}
