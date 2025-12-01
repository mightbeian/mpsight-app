/// Multimodal Patient Data Models
/// Integrates symptoms, text notes, metadata, and clinical history

import 'fitzpatrick_type.dart';
import 'segmentation_result.dart';

/// Patient symptom assessment
class SymptomAssessment {
  final bool hasFever;
  final double? temperature; // Celsius
  final bool hasMalaise;
  final bool hasLymphadenopathy;
  final List<LymphadenopathyLocation>? lymphLocations;
  final bool hasHeadache;
  final bool hasMyalgia;
  final bool hasSoreThroat;
  final bool hasPharyngitis;
  final bool hasChills;
  final bool hasNausea;
  final int? symptomDurationDays;
  final DateTime assessmentDate;

  SymptomAssessment({
    required this.hasFever,
    this.temperature,
    required this.hasMalaise,
    required this.hasLymphadenopathy,
    this.lymphLocations,
    required this.hasHeadache,
    required this.hasMyalgia,
    required this.hasSoreThroat,
    required this.hasPharyngitis,
    required this.hasChills,
    required this.hasNausea,
    this.symptomDurationDays,
    required this.assessmentDate,
  });

  /// Calculate prodromal symptom score
  int get prodromalScore {
    int score = 0;
    if (hasFever) score += 2;
    if (hasMalaise) score += 1;
    if (hasLymphadenopathy) score += 2;
    if (hasHeadache) score += 1;
    if (hasMyalgia) score += 1;
    if (hasSoreThroat) score += 1;
    if (hasPharyngitis) score += 1;
    if (hasChills) score += 1;
    return score;
  }

  Map<String, dynamic> toJson() => {
    'hasFever': hasFever,
    'temperature': temperature,
    'hasMalaise': hasMalaise,
    'hasLymphadenopathy': hasLymphadenopathy,
    'lymphLocations': lymphLocations?.map((l) => l.name).toList(),
    'hasHeadache': hasHeadache,
    'hasMyalgia': hasMyalgia,
    'hasSoreThroat': hasSoreThroat,
    'hasPharyngitis': hasPharyngitis,
    'hasChills': hasChills,
    'hasNausea': hasNausea,
    'symptomDurationDays': symptomDurationDays,
    'assessmentDate': assessmentDate.toIso8601String(),
  };
}

enum LymphadenopathyLocation {
  cervical,
  submandibular,
  axillary,
  inguinal,
  femoral,
}

/// Lesion metadata
class LesionMetadata {
  final BodyRegion? location;
  final DateTime? onsetDate;
  final int? daysFromOnset;
  final String? progressionNotes;
  final bool isFirstOutbreak;
  final int? previousOutbreakCount;
  final bool hasPain;
  final int? painLevel; // 0-10
  final bool hasItching;
  final int? itchingLevel; // 0-10

  LesionMetadata({
    this.location,
    this.onsetDate,
    this.daysFromOnset,
    this.progressionNotes,
    required this.isFirstOutbreak,
    this.previousOutbreakCount,
    required this.hasPain,
    this.painLevel,
    required this.hasItching,
    this.itchingLevel,
  });

  Map<String, dynamic> toJson() => {
    'location': location?.name,
    'onsetDate': onsetDate?.toIso8601String(),
    'daysFromOnset': daysFromOnset,
    'progressionNotes': progressionNotes,
    'isFirstOutbreak': isFirstOutbreak,
    'previousOutbreakCount': previousOutbreakCount,
    'hasPain': hasPain,
    'painLevel': painLevel,
    'hasItching': hasItching,
    'itchingLevel': itchingLevel,
  };
}

/// Contact tracing and exposure history
class ExposureHistory {
  final bool hasKnownExposure;
  final DateTime? exposureDate;
  final String? exposureContext; // e.g., household, travel, healthcare
  final bool hasRecentTravel;
  final List<String>? travelLocations;
  final bool isHealthcareWorker;
  final bool hasAnimalContact;
  final String? animalType;
  final bool hasSexualExposureRisk;
  final int? daysSinceExposure;

  ExposureHistory({
    required this.hasKnownExposure,
    this.exposureDate,
    this.exposureContext,
    required this.hasRecentTravel,
    this.travelLocations,
    required this.isHealthcareWorker,
    required this.hasAnimalContact,
    this.animalType,
    required this.hasSexualExposureRisk,
    this.daysSinceExposure,
  });

  /// Calculate exposure risk score
  int get exposureRiskScore {
    int score = 0;
    if (hasKnownExposure) score += 3;
    if (hasRecentTravel) score += 1;
    if (isHealthcareWorker) score += 1;
    if (hasAnimalContact) score += 2;
    if (hasSexualExposureRisk) score += 2;
    return score;
  }

  Map<String, dynamic> toJson() => {
    'hasKnownExposure': hasKnownExposure,
    'exposureDate': exposureDate?.toIso8601String(),
    'exposureContext': exposureContext,
    'hasRecentTravel': hasRecentTravel,
    'travelLocations': travelLocations,
    'isHealthcareWorker': isHealthcareWorker,
    'hasAnimalContact': hasAnimalContact,
    'animalType': animalType,
    'hasSexualExposureRisk': hasSexualExposureRisk,
    'daysSinceExposure': daysSinceExposure,
  };
}

/// Clinical text notes
class ClinicalNote {
  final String noteId;
  final String content;
  final String? authorIdHash; // Anonymized
  final DateTime createdAt;
  final DateTime? updatedAt;
  final NoteType noteType;
  final bool isStructured;

  ClinicalNote({
    required this.noteId,
    required this.content,
    this.authorIdHash,
    required this.createdAt,
    this.updatedAt,
    required this.noteType,
    required this.isStructured,
  });

  Map<String, dynamic> toJson() => {
    'noteId': noteId,
    'content': content,
    'authorIdHash': authorIdHash,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'noteType': noteType.name,
    'isStructured': isStructured,
  };
}

enum NoteType {
  initialAssessment,
  followUp,
  progressNote,
  treatmentPlan,
  dischargeSummary,
  consultation,
}

/// Complete patient assessment record
class PatientAssessment {
  final String assessmentId;
  final String patientIdHash; // Anonymized patient ID
  final DateTime assessmentDate;
  final SymptomAssessment symptoms;
  final LesionMetadata lesionMetadata;
  final ExposureHistory exposureHistory;
  final List<ClinicalNote> clinicalNotes;
  final FitzpatrickType? fitzpatrickType;
  final int? ageGroup; // e.g., 0: 0-17, 1: 18-34, 2: 35-49, 3: 50-64, 4: 65+
  final String? genderCode; // M, F, O, U
  final bool hasImmunocompromise;
  final bool isPregnant;
  final bool hasHIV;
  final List<String>? comorbidities;

  PatientAssessment({
    required this.assessmentId,
    required this.patientIdHash,
    required this.assessmentDate,
    required this.symptoms,
    required this.lesionMetadata,
    required this.exposureHistory,
    required this.clinicalNotes,
    this.fitzpatrickType,
    this.ageGroup,
    this.genderCode,
    required this.hasImmunocompromise,
    required this.isPregnant,
    required this.hasHIV,
    this.comorbidities,
  });

  /// Calculate overall risk score combining all factors
  int get overallRiskScore {
    int score = 0;
    score += symptoms.prodromalScore;
    score += exposureHistory.exposureRiskScore;
    if (hasImmunocompromise) score += 3;
    if (isPregnant) score += 2;
    if (hasHIV) score += 3;
    if (comorbidities != null && comorbidities!.isNotEmpty) {
      score += comorbidities!.length;
    }
    return score;
  }

  Map<String, dynamic> toJson() => {
    'assessmentId': assessmentId,
    'patientIdHash': patientIdHash,
    'assessmentDate': assessmentDate.toIso8601String(),
    'symptoms': symptoms.toJson(),
    'lesionMetadata': lesionMetadata.toJson(),
    'exposureHistory': exposureHistory.toJson(),
    'clinicalNotes': clinicalNotes.map((n) => n.toJson()).toList(),
    'fitzpatrickType': fitzpatrickType?.name,
    'ageGroup': ageGroup,
    'genderCode': genderCode,
    'hasImmunocompromise': hasImmunocompromise,
    'isPregnant': isPregnant,
    'hasHIV': hasHIV,
    'comorbidities': comorbidities,
  };
}
