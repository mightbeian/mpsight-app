import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class DetectionResult {
  final Map<String, double> confidences;
  final String primaryCondition;
  final double primaryConfidence;
  final DateTime timestamp;

  DetectionResult({
    required this.confidences,
    required this.primaryCondition,
    required this.primaryConfidence,
    required this.timestamp,
  });
}

class DetectionProvider extends ChangeNotifier {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;
  bool _isProcessing = false;
  DetectionResult? _lastResult;
  
  // Updated class labels matching MSLD v2.0 dataset (6 classes)
  // Order: Monkeypox, Chickenpox, Measles, Cowpox, HFMD, Healthy
  final List<String> _labels = [
    'Monkeypox',
    'Chickenpox',
    'Measles',
    'Cowpox',
    'HFMD',
    'Healthy',
  ];

  // Getters
  bool get isModelLoaded => _isModelLoaded;
  bool get isProcessing => _isProcessing;
  DetectionResult? get lastResult => _lastResult;
  List<String> get labels => _labels;

  // Initialize the TFLite model
  Future<void> loadModel() async {
    try {
      final options = InterpreterOptions()..threads = 4;
      
      // Load your YOLOv8 TFLite model (trained on MSLD v2.0)
      _interpreter = await Interpreter.fromAsset(
        'assets/models/yolov8_skin_classifier.tflite',
        options: options,
      );
      
      _isModelLoaded = true;
      notifyListeners();
      debugPrint('Model loaded successfully - 6 classes (MSLD v2.0)');
    } catch (e) {
      debugPrint('Error loading model: $e');
      _isModelLoaded = false;
      notifyListeners();
    }
  }

  // Process image for detection
  Future<DetectionResult?> detectSkinCondition(Uint8List imageBytes) async {
    if (!_isModelLoaded || _interpreter == null) {
      debugPrint('Model not loaded');
      return null;
    }

    _isProcessing = true;
    notifyListeners();

    try {
      // Decode image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Preprocess image (resize to 640x640 for YOLOv8)
      img.Image resizedImage = img.copyResize(
        image,
        width: 640,
        height: 640,
        interpolation: img.Interpolation.linear,
      );

      // Convert to float32 and normalize
      var input = _imageToByteListFloat32(resizedImage);

      // Prepare output tensor for 6 classes
      var output = List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);

      // Run inference
      _interpreter!.run(input, output);

      // Process results
      Map<String, double> confidences = {};
      double maxConfidence = 0.0;
      String primaryCondition = '';

      for (int i = 0; i < _labels.length; i++) {
        double confidence = (output[0][i] as double) * 100;
        confidences[_labels[i]] = confidence;
        
        if (confidence > maxConfidence) {
          maxConfidence = confidence;
          primaryCondition = _labels[i];
        }
      }

      _lastResult = DetectionResult(
        confidences: confidences,
        primaryCondition: primaryCondition,
        primaryConfidence: maxConfidence,
        timestamp: DateTime.now(),
      );

      _isProcessing = false;
      notifyListeners();

      return _lastResult;
    } catch (e) {
      debugPrint('Error during detection: $e');
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  // Convert image to Float32List for model input
  Float32List _imageToByteListFloat32(img.Image image) {
    var convertedBytes = Float32List(1 * 640 * 640 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int i = 0; i < 640; i++) {
      for (int j = 0; j < 640; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = pixel.r / 255.0;
        buffer[pixelIndex++] = pixel.g / 255.0;
        buffer[pixelIndex++] = pixel.b / 255.0;
      }
    }

    return convertedBytes.reshape([1, 640, 640, 3]);
  }

  void clearResults() {
    _lastResult = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }
}