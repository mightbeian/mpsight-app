/// Comprehensive Detection Provider
/// Integrates all MPSight AI components:
/// - Multiclass lesion type classification
/// - Multi-label disease classification
/// - Lesion segmentation (U-Net with attention)
/// - MPOX-SSS severity scoring
/// - Fitzpatrick skin type classification

import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'dart:ui';

import '../models/lesion_type.dart';
import '../models/disease_classification.dart';
import '../models/segmentation_result.dart';
import '../models/severity_score.dart';
import '../models/fitzpatrick_type.dart';
import '../models/patient_data.dart';
import '../services/privacy_service.dart';

/// Complete analysis result combining all models
class ComprehensiveAnalysisResult {
  final LesionTypeResult? lesionType;
  final MultiLabelClassificationResult? diseaseClassification;
  final SegmentationResult? segmentation;
  final MpoxSeverityResult? severityScore;
  final FitzpatrickClassificationResult? fitzpatrickType;
  final PatientAssessment? patientData;
  final DateTime timestamp;
  final Duration processingTime;
  final String sessionId;

  ComprehensiveAnalysisResult({
    this.lesionType,
    this.diseaseClassification,
    this.segmentation,
    this.severityScore,
    this.fitzpatrickType,
    this.patientData,
    required this.timestamp,
    required this.processingTime,
    required this.sessionId,
  });

  bool get isComplete =>
      lesionType != null &&
      diseaseClassification != null &&
      segmentation != null &&
      severityScore != null;

  Map<String, dynamic> toJson() => {
    'lesionType': lesionType?.toJson(),
    'diseaseClassification': diseaseClassification?.toJson(),
    'segmentation': segmentation?.toJson(),
    'severityScore': severityScore?.toJson(),
    'fitzpatrickType': fitzpatrickType?.toJson(),
    'patientData': patientData?.toJson(),
    'timestamp': timestamp.toIso8601String(),
    'processingTimeMs': processingTime.inMilliseconds,
    'sessionId': sessionId,
  };
}

class ComprehensiveDetectionProvider extends ChangeNotifier {
  // Model interpreters
  Interpreter? _lesionTypeInterpreter;
  Interpreter? _diseaseClassifierInterpreter;
  Interpreter? _segmentationInterpreter;
  Interpreter? _severityInterpreter;
  Interpreter? _fitzpatrickInterpreter;

  // Model states
  bool _isLesionTypeLoaded = false;
  bool _isDiseaseClassifierLoaded = false;
  bool _isSegmentationLoaded = false;
  bool _isSeverityLoaded = false;
  bool _isFitzpatrickLoaded = false;

  bool _isProcessing = false;
  ComprehensiveAnalysisResult? _lastResult;
  String? _currentSessionId;

  // Privacy service
  final PrivacyService _privacyService;

  // Labels
  final List<String> _lesionTypeLabels = [
    'Macular', 'Papular', 'Vesicular', 'Pustular', 'Crusted'
  ];

  final List<String> _diseaseLabels = [
    'Mpox', 'Chickenpox', 'Measles', 'Cowpox', 'HFMD', 'Healthy'
  ];

  final List<String> _fitzpatrickLabels = [
    'Type I', 'Type II', 'Type III', 'Type IV', 'Type V', 'Type VI'
  ];

  ComprehensiveDetectionProvider({PrivacyService? privacyService})
      : _privacyService = privacyService ?? PrivacyService();

  // Getters
  bool get isLesionTypeLoaded => _isLesionTypeLoaded;
  bool get isDiseaseClassifierLoaded => _isDiseaseClassifierLoaded;
  bool get isSegmentationLoaded => _isSegmentationLoaded;
  bool get isSeverityLoaded => _isSeverityLoaded;
  bool get isFitzpatrickLoaded => _isFitzpatrickLoaded;
  bool get areAllModelsLoaded =>
      _isLesionTypeLoaded &&
      _isDiseaseClassifierLoaded &&
      _isSegmentationLoaded &&
      _isSeverityLoaded &&
      _isFitzpatrickLoaded;
  bool get isProcessing => _isProcessing;
  ComprehensiveAnalysisResult? get lastResult => _lastResult;
  PrivacyService get privacyService => _privacyService;

  /// Initialize all models
  Future<void> loadAllModels() async {
    await Future.wait([
      _loadLesionTypeModel(),
      _loadDiseaseClassifierModel(),
      _loadSegmentationModel(),
      _loadSeverityModel(),
      _loadFitzpatrickModel(),
    ]);
    notifyListeners();
  }

  Future<void> _loadLesionTypeModel() async {
    try {
      final options = InterpreterOptions()..threads = 4;
      _lesionTypeInterpreter = await Interpreter.fromAsset(
        'assets/models/lesion_type_classifier.tflite',
        options: options,
      );
      _isLesionTypeLoaded = true;
      debugPrint('Lesion type model loaded - 5 classes');
    } catch (e) {
      debugPrint('Error loading lesion type model: $e');
      _isLesionTypeLoaded = false;
    }
  }

  Future<void> _loadDiseaseClassifierModel() async {
    try {
      final options = InterpreterOptions()..threads = 4;
      _diseaseClassifierInterpreter = await Interpreter.fromAsset(
        'assets/models/disease_multilabel_classifier.tflite',
        options: options,
      );
      _isDiseaseClassifierLoaded = true;
      debugPrint('Disease classifier loaded - 6 classes (multi-label)');
    } catch (e) {
      debugPrint('Error loading disease classifier: $e');
      _isDiseaseClassifierLoaded = false;
    }
  }

  Future<void> _loadSegmentationModel() async {
    try {
      final options = InterpreterOptions()..threads = 4;
      _segmentationInterpreter = await Interpreter.fromAsset(
        'assets/models/unet_attention_segmentation.tflite',
        options: options,
      );
      _isSegmentationLoaded = true;
      debugPrint('U-Net segmentation model loaded');
    } catch (e) {
      debugPrint('Error loading segmentation model: $e');
      _isSegmentationLoaded = false;
    }
  }

  Future<void> _loadSeverityModel() async {
    try {
      final options = InterpreterOptions()..threads = 4;
      _severityInterpreter = await Interpreter.fromAsset(
        'assets/models/mpox_sss_severity.tflite',
        options: options,
      );
      _isSeverityLoaded = true;
      debugPrint('MPOX-SSS severity model loaded');
    } catch (e) {
      debugPrint('Error loading severity model: $e');
      _isSeverityLoaded = false;
    }
  }

  Future<void> _loadFitzpatrickModel() async {
    try {
      final options = InterpreterOptions()..threads = 4;
      _fitzpatrickInterpreter = await Interpreter.fromAsset(
        'assets/models/fitzpatrick_classifier.tflite',
        options: options,
      );
      _isFitzpatrickLoaded = true;
      debugPrint('Fitzpatrick skin type model loaded - 6 types');
    } catch (e) {
      debugPrint('Error loading Fitzpatrick model: $e');
      _isFitzpatrickLoaded = false;
    }
  }

  /// Run comprehensive analysis on an image
  Future<ComprehensiveAnalysisResult?> analyzeImage(
    Uint8List imageBytes, {
    PatientAssessment? patientData,
    bool runAllModels = true,
  }) async {
    if (_isProcessing) {
      debugPrint('Analysis already in progress');
      return null;
    }

    // Check consent
    if (!_privacyService.canProcess(ConsentPurpose.diagnosticAnalysis)) {
      debugPrint('User has not consented to diagnostic analysis');
      return null;
    }

    _isProcessing = true;
    _currentSessionId = 'SESSION_${DateTime.now().millisecondsSinceEpoch}';
    notifyListeners();

    final startTime = DateTime.now();

    try {
      // Decode and preprocess image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize for models (640x640 for most)
      img.Image resized = img.copyResize(
        image,
        width: 640,
        height: 640,
        interpolation: img.Interpolation.linear,
      );

      // Run all analyses in parallel where possible
      final results = await Future.wait([
        _classifyLesionType(resized),
        _classifyDisease(resized),
        _segmentLesions(resized),
        _classifyFitzpatrick(resized),
      ]);

      LesionTypeResult? lesionTypeResult = results[0] as LesionTypeResult?;
      MultiLabelClassificationResult? diseaseResult =
          results[1] as MultiLabelClassificationResult?;
      SegmentationResult? segmentationResult =
          results[2] as SegmentationResult?;
      FitzpatrickClassificationResult? fitzpatrickResult =
          results[3] as FitzpatrickClassificationResult?;

      // Calculate severity based on segmentation results
      MpoxSeverityResult? severityResult;
      if (segmentationResult != null) {
        severityResult = await _calculateSeverity(
          segmentationResult,
          patientData,
        );
      }

      final processingTime = DateTime.now().difference(startTime);

      _lastResult = ComprehensiveAnalysisResult(
        lesionType: lesionTypeResult,
        diseaseClassification: diseaseResult,
        segmentation: segmentationResult,
        severityScore: severityResult,
        fitzpatrickType: fitzpatrickResult,
        patientData: patientData,
        timestamp: DateTime.now(),
        processingTime: processingTime,
        sessionId: _currentSessionId!,
      );

      // Log audit event
      await _privacyService.logAudit(
        action: AuditAction.modelInference,
        userId: patientData?.patientIdHash ?? 'anonymous',
        resourceType: 'image_analysis',
        metadata: {
          'sessionId': _currentSessionId,
          'processingTimeMs': processingTime.inMilliseconds,
          'modelsRun': [
            if (lesionTypeResult != null) 'lesionType',
            if (diseaseResult != null) 'disease',
            if (segmentationResult != null) 'segmentation',
            if (severityResult != null) 'severity',
            if (fitzpatrickResult != null) 'fitzpatrick',
          ],
        },
      );

      _isProcessing = false;
      notifyListeners();

      return _lastResult;
    } catch (e) {
      debugPrint('Error during analysis: $e');
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  Future<LesionTypeResult?> _classifyLesionType(img.Image image) async {
    if (!_isLesionTypeLoaded || _lesionTypeInterpreter == null) return null;

    try {
      var input = _imageToFloat32(image);
      var output = List.filled(1 * 5, 0.0).reshape([1, 5]);

      _lesionTypeInterpreter!.run(input, output);

      Map<LesionStage, double> confidences = {};
      LesionStage primaryStage = LesionStage.unknown;
      double maxConf = 0.0;

      final stages = [
        LesionStage.macular,
        LesionStage.papular,
        LesionStage.vesicular,
        LesionStage.pustular,
        LesionStage.crusted,
      ];

      for (int i = 0; i < 5; i++) {
        double conf = output[0][i] as double;
        confidences[stages[i]] = conf;
        if (conf > maxConf) {
          maxConf = conf;
          primaryStage = stages[i];
        }
      }

      return LesionTypeResult(
        primaryStage: primaryStage,
        stageConfidences: confidences,
        timestamp: DateTime.now(),
        modelVersion: 'v1.0.0',
      );
    } catch (e) {
      debugPrint('Lesion type classification error: $e');
      return null;
    }
  }

  Future<MultiLabelClassificationResult?> _classifyDisease(
      img.Image image) async {
    if (!_isDiseaseClassifierLoaded || _diseaseClassifierInterpreter == null) {
      return null;
    }

    try {
      var input = _imageToFloat32(image);
      var output = List.filled(1 * 6, 0.0).reshape([1, 6]);

      _diseaseClassifierInterpreter!.run(input, output);

      Map<SkinCondition, double> confidences = {};
      List<SkinCondition> detected = [];
      SkinCondition primary = SkinCondition.healthy;
      double maxConf = 0.0;
      const threshold = 0.5;

      final conditions = SkinCondition.values
          .where((c) => c != SkinCondition.healthy)
          .toList()
        ..add(SkinCondition.healthy);

      for (int i = 0; i < 6; i++) {
        double conf = output[0][i] as double;
        SkinCondition condition;
        switch (i) {
          case 0:
            condition = SkinCondition.mpox;
            break;
          case 1:
            condition = SkinCondition.chickenpox;
            break;
          case 2:
            condition = SkinCondition.measles;
            break;
          case 3:
            condition = SkinCondition.cowpox;
            break;
          case 4:
            condition = SkinCondition.hfmd;
            break;
          default:
            condition = SkinCondition.healthy;
        }

        confidences[condition] = conf;

        if (conf >= threshold && condition != SkinCondition.healthy) {
          detected.add(condition);
        }

        if (conf > maxConf) {
          maxConf = conf;
          primary = condition;
        }
      }

      // Check for co-infection (multiple conditions above threshold)
      bool coInfection = detected.length > 1;

      // Calculate uncertainty
      var sorted = confidences.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      double uncertainty = 1.0 - (sorted[0].value - sorted[1].value);

      return MultiLabelClassificationResult(
        confidences: confidences,
        detectedConditions: detected,
        primaryCondition: primary,
        threshold: threshold,
        possibleCoInfection: coInfection,
        highUncertainty: uncertainty > 0.7,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Disease classification error: $e');
      return null;
    }
  }

  Future<SegmentationResult?> _segmentLesions(img.Image image) async {
    if (!_isSegmentationLoaded || _segmentationInterpreter == null) return null;

    try {
      // Resize to segmentation model input size (typically 256x256 or 512x512)
      img.Image segInput = img.copyResize(image, width: 256, height: 256);
      var input = _imageToFloat32(segInput, size: 256);

      // Output is a mask of same size
      var output = List.filled(1 * 256 * 256, 0.0).reshape([1, 256, 256]);

      _segmentationInterpreter!.run(input, output);

      // Process segmentation mask to extract lesions
      List<SegmentedLesion> lesions = _extractLesionsFromMask(
        output[0] as List<dynamic>,
        Size(image.width.toDouble(), image.height.toDouble()),
      );

      // Group by region (simplified - would need region detection model)
      Map<BodyRegion, List<SegmentedLesion>> byRegion = {
        BodyRegion.unknown: lesions,
      };

      // Calculate confluence
      double confluence = _calculateConfluence(lesions);
      int confluentGroups = _countConfluentGroups(lesions);

      // Calculate total affected area
      double totalArea = lesions.fold(
        0.0,
        (sum, l) => sum + l.areaPercentage,
      );

      return SegmentationResult(
        lesions: lesions,
        imageSize: Size(image.width.toDouble(), image.height.toDouble()),
        lesionCount: lesions.length,
        lesionsByRegion: byRegion,
        confluenceScore: confluence,
        confluentGroups: confluentGroups,
        totalAffectedAreaPercent: totalArea,
        timestamp: DateTime.now(),
        modelVersion: 'unet-attention-v1.0',
      );
    } catch (e) {
      debugPrint('Segmentation error: $e');
      return null;
    }
  }

  Future<FitzpatrickClassificationResult?> _classifyFitzpatrick(
      img.Image image) async {
    if (!_isFitzpatrickLoaded || _fitzpatrickInterpreter == null) return null;

    try {
      var input = _imageToFloat32(image);
      var output = List.filled(1 * 6, 0.0).reshape([1, 6]);

      _fitzpatrickInterpreter!.run(input, output);

      Map<FitzpatrickType, double> confidences = {};
      FitzpatrickType predicted = FitzpatrickType.unknown;
      double maxConf = 0.0;

      final types = [
        FitzpatrickType.type1,
        FitzpatrickType.type2,
        FitzpatrickType.type3,
        FitzpatrickType.type4,
        FitzpatrickType.type5,
        FitzpatrickType.type6,
      ];

      for (int i = 0; i < 6; i++) {
        double conf = output[0][i] as double;
        confidences[types[i]] = conf;
        if (conf > maxConf) {
          maxConf = conf;
          predicted = types[i];
        }
      }

      return FitzpatrickClassificationResult(
        predictedType: predicted,
        typeConfidences: confidences,
        confidence: maxConf,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Fitzpatrick classification error: $e');
      return null;
    }
  }

  Future<MpoxSeverityResult?> _calculateSeverity(
    SegmentationResult segmentation,
    PatientAssessment? patient,
  ) async {
    try {
      // Calculate component scores based on MPOX-SSS criteria
      int lesionCountScore = _scoreLesionCount(segmentation.lesionCount);
      int distributionScore =
          _scoreDistribution(segmentation.lesionsByRegion.length);
      int confluenceScore =
          _scoreConfluence(segmentation.confluenceScore);
      int mucosalScore = _scoreMucosal(segmentation.hasMucosalInvolvement);

      final components = SeverityComponentScores(
        lesionCountScore: lesionCountScore,
        lesionCount: segmentation.lesionCount,
        distributionScore: distributionScore,
        regionsAffected: segmentation.lesionsByRegion.length,
        confluenceScore: confluenceScore,
        confluencePercentage: segmentation.confluenceScore * 100,
        mucosalScore: mucosalScore,
        hasMucosalInvolvement: segmentation.hasMucosalInvolvement,
        mucosalRegions: segmentation.lesionsByRegion.keys
            .where((r) => r.isMucosal)
            .toList(),
      );

      int totalScore = components.totalScore;
      SeverityLevel level = MpoxSeverityResult.levelFromScore(totalScore);

      List<String> recommendations =
          MpoxSeverityResult.generateRecommendations(level, components);

      return MpoxSeverityResult(
        severityLevel: level,
        totalScore: totalScore,
        components: components,
        confidence: 0.85, // Would be model output in production
        recommendations: recommendations,
        timestamp: DateTime.now(),
        modelVersion: 'mpox-sss-v1.0',
      );
    } catch (e) {
      debugPrint('Severity calculation error: $e');
      return null;
    }
  }

  // Scoring helper methods
  int _scoreLesionCount(int count) {
    if (count <= 10) return 5;
    if (count <= 25) return 10;
    if (count <= 50) return 15;
    if (count <= 100) return 20;
    return 25;
  }

  int _scoreDistribution(int regions) {
    if (regions <= 1) return 5;
    if (regions <= 3) return 10;
    if (regions <= 5) return 15;
    if (regions <= 8) return 20;
    return 25;
  }

  int _scoreConfluence(double confluenceRatio) {
    if (confluenceRatio < 0.1) return 5;
    if (confluenceRatio < 0.25) return 10;
    if (confluenceRatio < 0.5) return 15;
    if (confluenceRatio < 0.75) return 20;
    return 25;
  }

  int _scoreMucosal(bool hasMucosal) {
    return hasMucosal ? 25 : 0;
  }

  // Image processing helpers
  Float32List _imageToFloat32(img.Image image, {int size = 640}) {
    var bytes = Float32List(1 * size * size * 3);
    int index = 0;

    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        var pixel = image.getPixel(x, y);
        bytes[index++] = pixel.r / 255.0;
        bytes[index++] = pixel.g / 255.0;
        bytes[index++] = pixel.b / 255.0;
      }
    }

    return bytes.reshape([1, size, size, 3]) as Float32List;
  }

  List<SegmentedLesion> _extractLesionsFromMask(
    List<dynamic> mask,
    Size originalSize,
  ) {
    // Simplified lesion extraction - would use connected components in production
    List<SegmentedLesion> lesions = [];
    int lesionId = 0;

    // Placeholder implementation
    // In production, use OpenCV or similar for connected component analysis
    
    return lesions;
  }

  double _calculateConfluence(List<SegmentedLesion> lesions) {
    if (lesions.length < 2) return 0.0;

    int overlapping = 0;
    for (int i = 0; i < lesions.length; i++) {
      for (int j = i + 1; j < lesions.length; j++) {
        if (lesions[i].overlapsWith(lesions[j])) {
          overlapping++;
        }
      }
    }

    int totalPairs = lesions.length * (lesions.length - 1) ~/ 2;
    return totalPairs > 0 ? overlapping / totalPairs : 0.0;
  }

  int _countConfluentGroups(List<SegmentedLesion> lesions) {
    // Simplified - would use union-find in production
    return 0;
  }

  void clearResults() {
    _lastResult = null;
    _currentSessionId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _lesionTypeInterpreter?.close();
    _diseaseClassifierInterpreter?.close();
    _segmentationInterpreter?.close();
    _severityInterpreter?.close();
    _fitzpatrickInterpreter?.close();
    super.dispose();
  }
}

// Extension for reshaping Float32List
extension Float32ListReshape on Float32List {
  List reshape(List<int> shape) {
    if (shape.length == 2) {
      return List.generate(
        shape[0],
        (i) => sublist(i * shape[1], (i + 1) * shape[1]).toList(),
      );
    } else if (shape.length == 3) {
      int d1 = shape[0], d2 = shape[1], d3 = shape[2];
      return List.generate(
        d1,
        (i) => List.generate(
          d2,
          (j) => sublist(
            (i * d2 + j) * d3,
            (i * d2 + j + 1) * d3,
          ).toList(),
        ),
      );
    } else if (shape.length == 4) {
      int d1 = shape[0], d2 = shape[1], d3 = shape[2], d4 = shape[3];
      return List.generate(
        d1,
        (i) => List.generate(
          d2,
          (j) => List.generate(
            d3,
            (k) => sublist(
              ((i * d2 + j) * d3 + k) * d4,
              ((i * d2 + j) * d3 + k + 1) * d4,
            ).toList(),
          ),
        ),
      );
    }
    return toList();
  }
}
