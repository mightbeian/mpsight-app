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
    debugPrint('🔄 Starting model load...');
    try {
      final options = InterpreterOptions()..threads = 4;
      
      debugPrint('📂 Loading model: assets/models/best_fp32.tflite');
      // Load your YOLOv8 TFLite model (trained on MSLD v2.0)
      _interpreter = await Interpreter.fromAsset(
        'assets/models/best_fp32.tflite',
        options: options,
      );
      
      // Get input/output tensor info
      final inputTensors = _interpreter!.getInputTensors();
      final outputTensors = _interpreter!.getOutputTensors();
      
      debugPrint('📊 Input shape: ${inputTensors.first.shape}');
      debugPrint('📊 Output shape: ${outputTensors.first.shape}');
      debugPrint('📊 Model classes: $_labels');
      
      _isModelLoaded = true;
      notifyListeners();
      debugPrint('✅ Model loaded successfully - 6 classes (MSLD v2.0)');
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading model: $e');
      debugPrint('Stack trace: $stackTrace');
      _isModelLoaded = false;
      notifyListeners();
    }
  }

  // Process image for detection
  Future<DetectionResult?> detectSkinCondition(Uint8List imageBytes) async {
    debugPrint('🔍 Detection requested...');
    
    if (!_isModelLoaded || _interpreter == null) {
      debugPrint('❌ Model not loaded! isModelLoaded=$_isModelLoaded, interpreter=${_interpreter != null}');
      return null;
    }

    debugPrint('✅ Model ready, starting detection...');
    _isProcessing = true;
    notifyListeners();

    try {
      // Decode image
      debugPrint('📷 Decoding image (${imageBytes.length} bytes)...');
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }
      debugPrint('✅ Image decoded: ${image.width}x${image.height}');

      // Preprocess image (resize to 640x640 for YOLOv8)
      debugPrint('🔄 Resizing to 640x640...');
      img.Image resizedImage = img.copyResize(
        image,
        width: 640,
        height: 640,
        interpolation: img.Interpolation.linear,
      );

      // Convert to float32 and normalize
      debugPrint('🔄 Converting to Float32...');
      var input = _imageToByteListFloat32(resizedImage);
      var inputReshaped = input.reshape([1, 640, 640, 3]);

      // Prepare output tensor for 6 classes
      var output = List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);

      // Run inference
      debugPrint('🤖 Running inference...');
      _interpreter!.run(inputReshaped, output);
      debugPrint('✅ Inference complete!');

      // Debug raw output
      debugPrint('🔍 Raw model output:');
      for (int i = 0; i < _labels.length; i++) {
        debugPrint('  [$i] ${_labels[i]}: ${output[0][i]}');
      }

      // Process results
      Map<String, double> confidences = {};
      double maxConfidence = 0.0;
      String primaryCondition = '';

      for (int i = 0; i < _labels.length; i++) {
        // Model outputs raw logits or probabilities (0-1 range)
        // Don't multiply by 100 yet - check the raw values first
        double rawValue = output[0][i] as double;
        double confidence = rawValue;
        
        // If values are in 0-1 range, multiply by 100 for percentage
        if (rawValue <= 1.0) {
          confidence = rawValue * 100;
        }
        
        confidences[_labels[i]] = confidence;
        
        if (rawValue > maxConfidence) {
          maxConfidence = rawValue;
          primaryCondition = _labels[i];
        }
      }

      // Convert max confidence to percentage if needed
      double displayConfidence = maxConfidence <= 1.0 ? maxConfidence * 100 : maxConfidence;

      debugPrint('📊 Results: $primaryCondition (${displayConfidence.toStringAsFixed(1)}%)');
      debugPrint('📊 All confidences:');
      confidences.forEach((label, conf) {
        debugPrint('  $label: ${conf.toStringAsFixed(2)}%');
      });

      _lastResult = DetectionResult(
        confidences: confidences,
        primaryCondition: primaryCondition,
        primaryConfidence: displayConfidence,
        timestamp: DateTime.now(),
      );

      _isProcessing = false;
      notifyListeners();

      return _lastResult;
    } catch (e, stackTrace) {
      debugPrint('❌ Error during detection: $e');
      debugPrint('Stack trace: $stackTrace');
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  // Convert image to Float32List for model input
  Float32List _imageToByteListFloat32(img.Image image) {
    var convertedBytes = Float32List(1 * 640 * 640 * 3);
    int pixelIndex = 0;

    for (int i = 0; i < 640; i++) {
      for (int j = 0; j < 640; j++) {
        var pixel = image.getPixel(j, i);
        convertedBytes[pixelIndex++] = pixel.r / 255.0;
        convertedBytes[pixelIndex++] = pixel.g / 255.0;
        convertedBytes[pixelIndex++] = pixel.b / 255.0;
      }
    }

    return convertedBytes;
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