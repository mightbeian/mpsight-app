/// MPOX-SSS (Mpox Severity Scoring System) Models
/// Integrates lesion count, distribution, confluence, and mucosal involvement
/// Incorporates dermatologist ratings as ground truth

import 'segmentation_result.dart';

enum SeverityLevel {
  mild,
  moderate,
  severe,
}

extension SeverityLevelExtension on SeverityLevel {
  String get displayName {
    switch (this) {
      case SeverityLevel.mild:
        return 'Mild';
      case SeverityLevel.moderate:
        return 'Moderate';
      case SeverityLevel.severe:
        return 'Severe';
    }
  }

  String get clinicalGuidance {
    switch (this) {
      case SeverityLevel.mild:
        return 'Outpatient management with supportive care. Monitor for progression.';
      case SeverityLevel.moderate:
        return 'Consider antiviral therapy. Close monitoring recommended. May require frequent follow-up.';
      case SeverityLevel.severe:
        return 'Immediate medical attention required. Consider hospitalization. Antiviral therapy strongly recommended.';
    }
  }

  int get colorCode {
    switch (this) {
      case SeverityLevel.mild:
        return 0xFF4CAF50; // Green
      case SeverityLevel.moderate:
        return 0xFFFF9800; // Orange
      case SeverityLevel.severe:
        return 0xFFF44336; // Red
    }
  }
}

/// Individual component scores for MPOX-SSS
class SeverityComponentScores {
  /// Lesion count score (0-25 points)
  final int lesionCountScore;
  final int lesionCount;
  
  /// Regional distribution score (0-25 points)
  final int distributionScore;
  final int regionsAffected;
  
  /// Confluence score (0-25 points)
  final int confluenceScore;
  final double confluencePercentage;
  
  /// Mucosal involvement score (0-25 points)
  final int mucosalScore;
  final bool hasMucosalInvolvement;
  final List<BodyRegion> mucosalRegions;

  SeverityComponentScores({
    required this.lesionCountScore,
    required this.lesionCount,
    required this.distributionScore,
    required this.regionsAffected,
    required this.confluenceScore,
    required this.confluencePercentage,
    required this.mucosalScore,
    required this.hasMucosalInvolvement,
    required this.mucosalRegions,
  });

  int get totalScore =>
      lesionCountScore + distributionScore + confluenceScore + mucosalScore;

  Map<String, dynamic> toJson() => {
    'lesionCountScore': lesionCountScore,
    'lesionCount': lesionCount,
    'distributionScore': distributionScore,
    'regionsAffected': regionsAffected,
    'confluenceScore': confluenceScore,
    'confluencePercentage': confluencePercentage,
    'mucosalScore': mucosalScore,
    'hasMucosalInvolvement': hasMucosalInvolvement,
    'mucosalRegions': mucosalRegions.map((r) => r.name).toList(),
  };
}

/// Dermatologist rating for model training ground truth
class DermatologistRating {
  final String raterIdHash; // Anonymized rater ID
  final SeverityLevel assignedSeverity;
  final int overallScore; // 0-100
  final Map<String, int> componentScores;
  final String? clinicalNotes;
  final DateTime ratingDate;
  final int yearsExperience;
  final bool isBoardCertified;

  DermatologistRating({
    required this.raterIdHash,
    required this.assignedSeverity,
    required this.overallScore,
    required this.componentScores,
    this.clinicalNotes,
    required this.ratingDate,
    required this.yearsExperience,
    required this.isBoardCertified,
  });

  Map<String, dynamic> toJson() => {
    'raterIdHash': raterIdHash,
    'assignedSeverity': assignedSeverity.name,
    'overallScore': overallScore,
    'componentScores': componentScores,
    'clinicalNotes': clinicalNotes,
    'ratingDate': ratingDate.toIso8601String(),
    'yearsExperience': yearsExperience,
    'isBoardCertified': isBoardCertified,
  };

  factory DermatologistRating.fromJson(Map<String, dynamic> json) {
    return DermatologistRating(
      raterIdHash: json['raterIdHash'],
      assignedSeverity: SeverityLevel.values.firstWhere(
        (e) => e.name == json['assignedSeverity'],
      ),
      overallScore: json['overallScore'],
      componentScores: Map<String, int>.from(json['componentScores']),
      clinicalNotes: json['clinicalNotes'],
      ratingDate: DateTime.parse(json['ratingDate']),
      yearsExperience: json['yearsExperience'],
      isBoardCertified: json['isBoardCertified'],
    );
  }
}

/// Complete MPOX-SSS Result
class MpoxSeverityResult {
  /// Calculated severity level
  final SeverityLevel severityLevel;
  
  /// Total score (0-100)
  final int totalScore;
  
  /// Component breakdown
  final SeverityComponentScores components;
  
  /// Model confidence in this assessment
  final double confidence;
  
  /// Dermatologist ratings used for training (if available)
  final List<DermatologistRating>? trainingRatings;
  
  /// Inter-rater agreement score for training data
  final double? interRaterAgreement;
  
  /// Comparison to dermatologist consensus (if available)
  final double? agreementWithConsensus;
  
  /// Clinical recommendations based on severity
  final List<String> recommendations;
  
  /// Processing timestamp
  final DateTime timestamp;
  
  /// Model version
  final String? modelVersion;

  MpoxSeverityResult({
    required this.severityLevel,
    required this.totalScore,
    required this.components,
    required this.confidence,
    this.trainingRatings,
    this.interRaterAgreement,
    this.agreementWithConsensus,
    required this.recommendations,
    required this.timestamp,
    this.modelVersion,
  });

  /// Calculate severity level from total score
  static SeverityLevel levelFromScore(int score) {
    if (score <= 33) return SeverityLevel.mild;
    if (score <= 66) return SeverityLevel.moderate;
    return SeverityLevel.severe;
  }

  /// Generate clinical recommendations based on severity
  static List<String> generateRecommendations(SeverityLevel level, SeverityComponentScores components) {
    List<String> recs = [];
    
    switch (level) {
      case SeverityLevel.mild:
        recs.add('Symptomatic treatment with analgesics as needed');
        recs.add('Maintain proper hygiene and wound care');
        recs.add('Self-isolation until all lesions have crusted');
        recs.add('Follow-up in 7-14 days or if symptoms worsen');
        break;
      case SeverityLevel.moderate:
        recs.add('Consider tecovirimat (TPOXX) antiviral therapy');
        recs.add('Pain management protocol');
        recs.add('Bacterial superinfection monitoring');
        recs.add('Weekly follow-up recommended');
        if (components.hasMucosalInvolvement) {
          recs.add('Specialist referral for mucosal involvement');
        }
        break;
      case SeverityLevel.severe:
        recs.add('URGENT: Immediate medical evaluation required');
        recs.add('Tecovirimat (TPOXX) antiviral therapy strongly recommended');
        recs.add('Consider hospitalization for monitoring');
        recs.add('Pain management with possible opioid therapy');
        recs.add('Nutritional support assessment');
        if (components.hasMucosalInvolvement) {
          recs.add('URGENT: Ophthalmology/ENT/Urology consult for mucosal involvement');
        }
        break;
    }
    
    return recs;
  }

  Map<String, dynamic> toJson() => {
    'severityLevel': severityLevel.name,
    'totalScore': totalScore,
    'components': components.toJson(),
    'confidence': confidence,
    'interRaterAgreement': interRaterAgreement,
    'agreementWithConsensus': agreementWithConsensus,
    'recommendations': recommendations,
    'timestamp': timestamp.toIso8601String(),
    'modelVersion': modelVersion,
  };
}
