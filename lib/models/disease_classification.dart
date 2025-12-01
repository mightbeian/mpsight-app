/// Multi-Label Disease Classification Models
/// Supports simultaneous detection of multiple skin conditions
/// including co-infection scenarios

enum SkinCondition {
  mpox,
  chickenpox,
  measles,
  cowpox,
  hfmd,
  healthy,
}

extension SkinConditionExtension on SkinCondition {
  String get displayName {
    switch (this) {
      case SkinCondition.mpox:
        return 'Mpox (Monkeypox)';
      case SkinCondition.chickenpox:
        return 'Chickenpox';
      case SkinCondition.measles:
        return 'Measles';
      case SkinCondition.cowpox:
        return 'Cowpox';
      case SkinCondition.hfmd:
        return 'Hand, Foot & Mouth Disease';
      case SkinCondition.healthy:
        return 'Healthy Skin';
    }
  }

  String get shortName {
    switch (this) {
      case SkinCondition.mpox:
        return 'Mpox';
      case SkinCondition.chickenpox:
        return 'Chickenpox';
      case SkinCondition.measles:
        return 'Measles';
      case SkinCondition.cowpox:
        return 'Cowpox';
      case SkinCondition.hfmd:
        return 'HFMD';
      case SkinCondition.healthy:
        return 'Healthy';
    }
  }

  /// ICD-10 codes for reference
  String get icd10Code {
    switch (this) {
      case SkinCondition.mpox:
        return 'B04';
      case SkinCondition.chickenpox:
        return 'B01';
      case SkinCondition.measles:
        return 'B05';
      case SkinCondition.cowpox:
        return 'B08.010';
      case SkinCondition.hfmd:
        return 'B08.4';
      case SkinCondition.healthy:
        return 'Z00.00';
    }
  }
}

class MultiLabelClassificationResult {
  /// Confidence scores for each condition (0.0 - 1.0)
  final Map<SkinCondition, double> confidences;
  
  /// Conditions detected above threshold
  final List<SkinCondition> detectedConditions;
  
  /// Primary (highest confidence) condition
  final SkinCondition primaryCondition;
  
  /// Classification threshold used
  final double threshold;
  
  /// Indicates potential co-infection
  final bool possibleCoInfection;
  
  /// Uncertainty flag for borderline cases
  final bool highUncertainty;
  
  final DateTime timestamp;

  MultiLabelClassificationResult({
    required this.confidences,
    required this.detectedConditions,
    required this.primaryCondition,
    this.threshold = 0.5,
    required this.possibleCoInfection,
    required this.highUncertainty,
    required this.timestamp,
  });

  /// Check if a specific condition is detected
  bool hasCondition(SkinCondition condition) {
    return detectedConditions.contains(condition);
  }

  /// Get confidence for specific condition as percentage
  double getConfidencePercent(SkinCondition condition) {
    return (confidences[condition] ?? 0.0) * 100;
  }

  /// Get sorted conditions by confidence
  List<MapEntry<SkinCondition, double>> get sortedByConfidence {
    var entries = confidences.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  /// Calculate diagnostic uncertainty score
  double get uncertaintyScore {
    if (confidences.isEmpty) return 1.0;
    
    var sorted = sortedByConfidence;
    if (sorted.length < 2) return 0.0;
    
    // Uncertainty based on difference between top two predictions
    double diff = sorted[0].value - sorted[1].value;
    return 1.0 - diff;
  }

  Map<String, dynamic> toJson() => {
    'confidences': confidences.map((k, v) => MapEntry(k.name, v)),
    'detectedConditions': detectedConditions.map((c) => c.name).toList(),
    'primaryCondition': primaryCondition.name,
    'threshold': threshold,
    'possibleCoInfection': possibleCoInfection,
    'highUncertainty': highUncertainty,
    'timestamp': timestamp.toIso8601String(),
  };

  factory MultiLabelClassificationResult.fromJson(Map<String, dynamic> json) {
    return MultiLabelClassificationResult(
      confidences: (json['confidences'] as Map).map(
        (k, v) => MapEntry(
          SkinCondition.values.firstWhere((e) => e.name == k),
          (v as num).toDouble(),
        ),
      ),
      detectedConditions: (json['detectedConditions'] as List)
          .map((c) => SkinCondition.values.firstWhere((e) => e.name == c))
          .toList(),
      primaryCondition: SkinCondition.values.firstWhere(
        (e) => e.name == json['primaryCondition'],
      ),
      threshold: (json['threshold'] as num).toDouble(),
      possibleCoInfection: json['possibleCoInfection'] as bool,
      highUncertainty: json['highUncertainty'] as bool,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
