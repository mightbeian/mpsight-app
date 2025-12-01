/// Mpox Severity Scoring System (MPOX_SSS)
/// Based on WHO guidelines for clinical severity assessment

enum SeverityLevel {
  mild,
  moderate,
  severe,
  critical,
}

enum SkinLesionSeverity {
  none,
  mild,      // <25 lesions
  moderate,  // 25-100 lesions
  severe,    // 101-250 lesions
  verySevere, // >250 lesions
}

enum MucosalInvolvement {
  none,
  mild,      // 1 site
  moderate,  // 2 sites
  severe,    // ≥3 sites or extensive involvement
}

class ClinicalSymptom {
  final String name;
  final String category;
  final int score;
  final bool isPresent;
  final String? notes;

  ClinicalSymptom({
    required this.name,
    required this.category,
    required this.score,
    this.isPresent = false,
    this.notes,
  });

  ClinicalSymptom copyWith({
    bool? isPresent,
    String? notes,
  }) {
    return ClinicalSymptom(
      name: name,
      category: category,
      score: score,
      isPresent: isPresent ?? this.isPresent,
      notes: notes ?? this.notes,
    );
  }
}

class SeverityAssessment {
  final int totalScore;
  final SeverityLevel severityLevel;
  final SkinLesionSeverity lesionSeverity;
  final MucosalInvolvement mucosalInvolvement;
  final List<ClinicalSymptom> symptoms;
  final List<String> recommendations;
  final bool requiresHospitalization;
  final bool requiresICU;
  final DateTime assessmentDate;

  SeverityAssessment({
    required this.totalScore,
    required this.severityLevel,
    required this.lesionSeverity,
    required this.mucosalInvolvement,
    required this.symptoms,
    required this.recommendations,
    required this.requiresHospitalization,
    required this.requiresICU,
    required this.assessmentDate,
  });

  String get severityDescription {
    switch (severityLevel) {
      case SeverityLevel.mild:
        return 'Mild - Manageable with supportive care';
      case SeverityLevel.moderate:
        return 'Moderate - Requires close monitoring';
      case SeverityLevel.severe:
        return 'Severe - Hospitalization recommended';
      case SeverityLevel.critical:
        return 'Critical - Immediate medical attention required';
    }
  }

  String get lesionSeverityDescription {
    switch (lesionSeverity) {
      case SkinLesionSeverity.none:
        return 'No visible lesions';
      case SkinLesionSeverity.mild:
        return 'Mild (<25 lesions)';
      case SkinLesionSeverity.moderate:
        return 'Moderate (25-100 lesions)';
      case SkinLesionSeverity.severe:
        return 'Severe (101-250 lesions)';
      case SkinLesionSeverity.verySevere:
        return 'Very Severe (>250 lesions)';
    }
  }

  Map<String, int> get symptomScoresByCategory {
    Map<String, int> categoryScores = {};
    for (var symptom in symptoms) {
      if (symptom.isPresent) {
        categoryScores[symptom.category] = 
            (categoryScores[symptom.category] ?? 0) + symptom.score;
      }
    }
    return categoryScores;
  }
}

class SeverityCalculator {
  // Define all clinical symptoms with their scores
  static List<ClinicalSymptom> getDefaultSymptoms() {
    return [
      // Constitutional Symptoms (0-3 points each)
      ClinicalSymptom(name: 'Fever >38°C', category: 'Constitutional', score: 1),
      ClinicalSymptom(name: 'Severe Fatigue', category: 'Constitutional', score: 2),
      ClinicalSymptom(name: 'Myalgia (Muscle pain)', category: 'Constitutional', score: 1),
      ClinicalSymptom(name: 'Headache', category: 'Constitutional', score: 1),
      ClinicalSymptom(name: 'Lymphadenopathy', category: 'Constitutional', score: 2),

      // Respiratory Symptoms (1-4 points each)
      ClinicalSymptom(name: 'Cough', category: 'Respiratory', score: 1),
      ClinicalSymptom(name: 'Sore Throat', category: 'Respiratory', score: 1),
      ClinicalSymptom(name: 'Difficulty Breathing', category: 'Respiratory', score: 4),
      ClinicalSymptom(name: 'Chest Pain', category: 'Respiratory', score: 3),

      // Gastrointestinal Symptoms (1-3 points each)
      ClinicalSymptom(name: 'Nausea/Vomiting', category: 'Gastrointestinal', score: 2),
      ClinicalSymptom(name: 'Diarrhea', category: 'Gastrointestinal', score: 2),
      ClinicalSymptom(name: 'Abdominal Pain', category: 'Gastrointestinal', score: 2),
      ClinicalSymptom(name: 'Severe Dehydration', category: 'Gastrointestinal', score: 3),

      // Neurological Symptoms (3-5 points each)
      ClinicalSymptom(name: 'Confusion/Altered Mental Status', category: 'Neurological', score: 5),
      ClinicalSymptom(name: 'Seizures', category: 'Neurological', score: 5),
      ClinicalSymptom(name: 'Severe Headache', category: 'Neurological', score: 3),

      // Dermatological Complications (2-4 points each)
      ClinicalSymptom(name: 'Secondary Bacterial Infection', category: 'Dermatological', score: 3),
      ClinicalSymptom(name: 'Severe Pain at Lesion Sites', category: 'Dermatological', score: 2),
      ClinicalSymptom(name: 'Bleeding from Lesions', category: 'Dermatological', score: 4),
      ClinicalSymptom(name: 'Necrosis', category: 'Dermatological', score: 4),

      // Ocular Symptoms (2-4 points each)
      ClinicalSymptom(name: 'Eye Pain', category: 'Ocular', score: 2),
      ClinicalSymptom(name: 'Photophobia', category: 'Ocular', score: 2),
      ClinicalSymptom(name: 'Vision Changes', category: 'Ocular', score: 4),
      ClinicalSymptom(name: 'Corneal Lesions', category: 'Ocular', score: 4),
    ];
  }

  static SeverityAssessment calculateSeverity({
    required List<ClinicalSymptom> symptoms,
    required SkinLesionSeverity lesionSeverity,
    required MucosalInvolvement mucosalInvolvement,
    int? lesionCount,
  }) {
    // Calculate base score from symptoms
    int symptomScore = 0;
    for (var symptom in symptoms) {
      if (symptom.isPresent) {
        symptomScore += symptom.score;
      }
    }

    // Add lesion severity score
    int lesionScore = _getLesionScore(lesionSeverity);
    
    // Add mucosal involvement score
    int mucosalScore = _getMucosalScore(mucosalInvolvement);

    // Calculate total score
    int totalScore = symptomScore + lesionScore + mucosalScore;

    // Determine severity level
    SeverityLevel severityLevel = _determineSeverityLevel(totalScore, symptoms);

    // Generate recommendations
    List<String> recommendations = _generateRecommendations(
      severityLevel,
      lesionSeverity,
      mucosalInvolvement,
      symptoms,
    );

    // Determine hospitalization needs
    bool requiresHospitalization = _requiresHospitalization(severityLevel, symptoms);
    bool requiresICU = _requiresICU(severityLevel, symptoms);

    return SeverityAssessment(
      totalScore: totalScore,
      severityLevel: severityLevel,
      lesionSeverity: lesionSeverity,
      mucosalInvolvement: mucosalInvolvement,
      symptoms: symptoms,
      recommendations: recommendations,
      requiresHospitalization: requiresHospitalization,
      requiresICU: requiresICU,
      assessmentDate: DateTime.now(),
    );
  }

  static int _getLesionScore(SkinLesionSeverity severity) {
    switch (severity) {
      case SkinLesionSeverity.none:
        return 0;
      case SkinLesionSeverity.mild:
        return 2;
      case SkinLesionSeverity.moderate:
        return 4;
      case SkinLesionSeverity.severe:
        return 6;
      case SkinLesionSeverity.verySevere:
        return 8;
    }
  }

  static int _getMucosalScore(MucosalInvolvement involvement) {
    switch (involvement) {
      case MucosalInvolvement.none:
        return 0;
      case MucosalInvolvement.mild:
        return 2;
      case MucosalInvolvement.moderate:
        return 4;
      case MucosalInvolvement.severe:
        return 6;
    }
  }

  static SeverityLevel _determineSeverityLevel(int totalScore, List<ClinicalSymptom> symptoms) {
    // Check for critical symptoms regardless of score
    bool hasCriticalSymptoms = symptoms.any((s) => 
      s.isPresent && (
        s.name.contains('Confusion') ||
        s.name.contains('Seizures') ||
        s.name.contains('Difficulty Breathing') ||
        s.name.contains('Vision Changes') ||
        s.name.contains('Corneal Lesions')
      )
    );

    if (hasCriticalSymptoms || totalScore >= 25) {
      return SeverityLevel.critical;
    } else if (totalScore >= 15) {
      return SeverityLevel.severe;
    } else if (totalScore >= 8) {
      return SeverityLevel.moderate;
    } else {
      return SeverityLevel.mild;
    }
  }

  static List<String> _generateRecommendations(
    SeverityLevel level,
    SkinLesionSeverity lesionSeverity,
    MucosalInvolvement mucosalInvolvement,
    List<ClinicalSymptom> symptoms,
  ) {
    List<String> recommendations = [];

    switch (level) {
      case SeverityLevel.mild:
        recommendations.addAll([
          'Home isolation and self-care',
          'Monitor symptoms daily',
          'Keep lesions clean and covered',
          'Stay hydrated',
          'Take pain relievers as needed',
          'Avoid contact with others until lesions heal',
        ]);
        break;

      case SeverityLevel.moderate:
        recommendations.addAll([
          'Contact healthcare provider for evaluation',
          'Consider outpatient monitoring',
          'Pain management may be required',
          'Watch for signs of secondary infection',
          'Monitor for worsening symptoms',
          'Consider antiviral therapy consultation',
        ]);
        break;

      case SeverityLevel.severe:
        recommendations.addAll([
          '⚠️ SEEK MEDICAL ATTENTION IMMEDIATELY',
          'Hospital admission recommended',
          'Antiviral therapy (Tecovirimat) may be indicated',
          'IV fluids may be necessary',
          'Wound care by medical professionals',
          'Isolation precautions required',
        ]);
        break;

      case SeverityLevel.critical:
        recommendations.addAll([
          '🚨 EMERGENCY CARE REQUIRED',
          'Call emergency services or go to ER',
          'ICU admission may be necessary',
          'Aggressive supportive care needed',
          'Antiviral therapy indicated',
          'Close monitoring of vital signs',
          'Specialist consultations required',
        ]);
        break;
    }

    // Add specific recommendations based on symptoms
    if (mucosalInvolvement != MucosalInvolvement.none) {
      recommendations.add('Soft diet and oral care for mucosal lesions');
    }

    if (lesionSeverity == SkinLesionSeverity.severe || 
        lesionSeverity == SkinLesionSeverity.verySevere) {
      recommendations.add('Regular wound care and dressing changes needed');
    }

    // Check for specific symptom-based recommendations
    for (var symptom in symptoms) {
      if (symptom.isPresent) {
        if (symptom.category == 'Ocular') {
          recommendations.add('Ophthalmology consultation required');
        }
        if (symptom.name.contains('Dehydration')) {
          recommendations.add('Immediate rehydration therapy needed');
        }
      }
    }

    return recommendations;
  }

  static bool _requiresHospitalization(SeverityLevel level, List<ClinicalSymptom> symptoms) {
    return level == SeverityLevel.severe || 
           level == SeverityLevel.critical ||
           symptoms.any((s) => s.isPresent && s.score >= 4);
  }

  static bool _requiresICU(SeverityLevel level, List<ClinicalSymptom> symptoms) {
    return level == SeverityLevel.critical ||
           symptoms.any((s) => s.isPresent && (
             s.name.contains('Confusion') ||
             s.name.contains('Seizures') ||
             s.name.contains('Difficulty Breathing')
           ));
  }
}
