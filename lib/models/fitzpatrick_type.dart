/// Fitzpatrick Skin Type Classification
/// For evaluating model performance across diverse skin tones
/// Addresses potential algorithmic bias in skin type representation

enum FitzpatrickType {
  type1,
  type2,
  type3,
  type4,
  type5,
  type6,
  unknown,
}

extension FitzpatrickTypeExtension on FitzpatrickType {
  String get displayName {
    switch (this) {
      case FitzpatrickType.type1:
        return 'Type I';
      case FitzpatrickType.type2:
        return 'Type II';
      case FitzpatrickType.type3:
        return 'Type III';
      case FitzpatrickType.type4:
        return 'Type IV';
      case FitzpatrickType.type5:
        return 'Type V';
      case FitzpatrickType.type6:
        return 'Type VI';
      case FitzpatrickType.unknown:
        return 'Unknown';
    }
  }

  String get description {
    switch (this) {
      case FitzpatrickType.type1:
        return 'Very fair skin, always burns, never tans';
      case FitzpatrickType.type2:
        return 'Fair skin, usually burns, tans minimally';
      case FitzpatrickType.type3:
        return 'Medium skin, sometimes burns, tans uniformly';
      case FitzpatrickType.type4:
        return 'Olive skin, burns minimally, always tans well';
      case FitzpatrickType.type5:
        return 'Brown skin, rarely burns, tans darkly';
      case FitzpatrickType.type6:
        return 'Dark brown/black skin, never burns';
      case FitzpatrickType.unknown:
        return 'Unable to classify';
    }
  }

  /// Typical melanin index range
  (double, double) get melaninIndexRange {
    switch (this) {
      case FitzpatrickType.type1:
        return (0.0, 0.15);
      case FitzpatrickType.type2:
        return (0.15, 0.30);
      case FitzpatrickType.type3:
        return (0.30, 0.45);
      case FitzpatrickType.type4:
        return (0.45, 0.60);
      case FitzpatrickType.type5:
        return (0.60, 0.80);
      case FitzpatrickType.type6:
        return (0.80, 1.0);
      case FitzpatrickType.unknown:
        return (0.0, 1.0);
    }
  }
}

class FitzpatrickClassificationResult {
  final FitzpatrickType predictedType;
  final Map<FitzpatrickType, double> typeConfidences;
  final double confidence;
  final DateTime timestamp;

  FitzpatrickClassificationResult({
    required this.predictedType,
    required this.typeConfidences,
    required this.confidence,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'predictedType': predictedType.name,
    'typeConfidences': typeConfidences.map((k, v) => MapEntry(k.name, v)),
    'confidence': confidence,
    'timestamp': timestamp.toIso8601String(),
  };

  factory FitzpatrickClassificationResult.fromJson(Map<String, dynamic> json) {
    return FitzpatrickClassificationResult(
      predictedType: FitzpatrickType.values.firstWhere(
        (e) => e.name == json['predictedType'],
        orElse: () => FitzpatrickType.unknown,
      ),
      typeConfidences: (json['typeConfidences'] as Map).map(
        (k, v) => MapEntry(
          FitzpatrickType.values.firstWhere(
            (e) => e.name == k,
            orElse: () => FitzpatrickType.unknown,
          ),
          (v as num).toDouble(),
        ),
      ),
      confidence: (json['confidence'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// Performance metrics per Fitzpatrick type for bias evaluation
class FitzpatrickPerformanceMetrics {
  final FitzpatrickType skinType;
  final int sampleCount;
  final double accuracy;
  final double precision;
  final double recall;
  final double f1Score;
  final double auc;
  final double falsePositiveRate;
  final double falseNegativeRate;

  FitzpatrickPerformanceMetrics({
    required this.skinType,
    required this.sampleCount,
    required this.accuracy,
    required this.precision,
    required this.recall,
    required this.f1Score,
    required this.auc,
    required this.falsePositiveRate,
    required this.falseNegativeRate,
  });

  /// Check if performance meets equity threshold
  bool meetsEquityThreshold({
    required double baselineAccuracy,
    double maxDeviation = 0.05,
  }) {
    return (accuracy - baselineAccuracy).abs() <= maxDeviation;
  }

  Map<String, dynamic> toJson() => {
    'skinType': skinType.name,
    'sampleCount': sampleCount,
    'accuracy': accuracy,
    'precision': precision,
    'recall': recall,
    'f1Score': f1Score,
    'auc': auc,
    'falsePositiveRate': falsePositiveRate,
    'falseNegativeRate': falseNegativeRate,
  };
}

/// Aggregate bias evaluation across all skin types
class BiasEvaluationReport {
  final Map<FitzpatrickType, FitzpatrickPerformanceMetrics> metricsByType;
  final double overallAccuracy;
  final double maxAccuracyDisparity;
  final double demographicParityScore;
  final double equalizedOddsScore;
  final bool passesEquityCheck;
  final List<String> biasWarnings;
  final DateTime evaluationDate;

  BiasEvaluationReport({
    required this.metricsByType,
    required this.overallAccuracy,
    required this.maxAccuracyDisparity,
    required this.demographicParityScore,
    required this.equalizedOddsScore,
    required this.passesEquityCheck,
    required this.biasWarnings,
    required this.evaluationDate,
  });

  Map<String, dynamic> toJson() => {
    'metricsByType': metricsByType.map((k, v) => MapEntry(k.name, v.toJson())),
    'overallAccuracy': overallAccuracy,
    'maxAccuracyDisparity': maxAccuracyDisparity,
    'demographicParityScore': demographicParityScore,
    'equalizedOddsScore': equalizedOddsScore,
    'passesEquityCheck': passesEquityCheck,
    'biasWarnings': biasWarnings,
    'evaluationDate': evaluationDate.toIso8601String(),
  };
}
