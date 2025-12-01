/// Lesion Type Classification Models
/// Supports multiclass classification of lesion stages

enum LesionStage {
  macular,
  papular,
  vesicular,
  pustular,
  crusted,
  unknown,
}

extension LesionStageExtension on LesionStage {
  String get displayName {
    switch (this) {
      case LesionStage.macular:
        return 'Macular';
      case LesionStage.papular:
        return 'Papular';
      case LesionStage.vesicular:
        return 'Vesicular';
      case LesionStage.pustular:
        return 'Pustular';
      case LesionStage.crusted:
        return 'Crusted';
      case LesionStage.unknown:
        return 'Unknown';
    }
  }

  String get description {
    switch (this) {
      case LesionStage.macular:
        return 'Flat, discolored skin patches';
      case LesionStage.papular:
        return 'Raised, solid bumps';
      case LesionStage.vesicular:
        return 'Fluid-filled blisters';
      case LesionStage.pustular:
        return 'Pus-filled lesions';
      case LesionStage.crusted:
        return 'Dried, scabbed lesions';
      case LesionStage.unknown:
        return 'Unable to classify';
    }
  }

  int get progressionOrder {
    switch (this) {
      case LesionStage.macular:
        return 1;
      case LesionStage.papular:
        return 2;
      case LesionStage.vesicular:
        return 3;
      case LesionStage.pustular:
        return 4;
      case LesionStage.crusted:
        return 5;
      case LesionStage.unknown:
        return 0;
    }
  }
}

class LesionTypeResult {
  final LesionStage primaryStage;
  final Map<LesionStage, double> stageConfidences;
  final DateTime timestamp;
  final String? modelVersion;

  LesionTypeResult({
    required this.primaryStage,
    required this.stageConfidences,
    required this.timestamp,
    this.modelVersion,
  });

  /// Get stages sorted by confidence
  List<MapEntry<LesionStage, double>> get sortedConfidences {
    var entries = stageConfidences.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  /// Check if classification is confident (above threshold)
  bool isConfident({double threshold = 0.7}) {
    return stageConfidences[primaryStage]! >= threshold;
  }

  Map<String, dynamic> toJson() => {
    'primaryStage': primaryStage.name,
    'stageConfidences': stageConfidences.map(
      (k, v) => MapEntry(k.name, v),
    ),
    'timestamp': timestamp.toIso8601String(),
    'modelVersion': modelVersion,
  };

  factory LesionTypeResult.fromJson(Map<String, dynamic> json) {
    return LesionTypeResult(
      primaryStage: LesionStage.values.firstWhere(
        (e) => e.name == json['primaryStage'],
        orElse: () => LesionStage.unknown,
      ),
      stageConfidences: (json['stageConfidences'] as Map).map(
        (k, v) => MapEntry(
          LesionStage.values.firstWhere(
            (e) => e.name == k,
            orElse: () => LesionStage.unknown,
          ),
          (v as num).toDouble(),
        ),
      ),
      timestamp: DateTime.parse(json['timestamp']),
      modelVersion: json['modelVersion'],
    );
  }
}
