import 'package:flutter/foundation.dart';
import '../models/severity_assessment.dart';

class SeverityProvider extends ChangeNotifier {
  List<ClinicalSymptom> _symptoms = [];
  SkinLesionSeverity _lesionSeverity = SkinLesionSeverity.none;
  MucosalInvolvement _mucosalInvolvement = MucosalInvolvement.none;
  SeverityAssessment? _currentAssessment;
  int? _estimatedLesionCount;

  // Getters
  List<ClinicalSymptom> get symptoms => _symptoms;
  SkinLesionSeverity get lesionSeverity => _lesionSeverity;
  MucosalInvolvement get mucosalInvolvement => _mucosalInvolvement;
  SeverityAssessment? get currentAssessment => _currentAssessment;
  int? get estimatedLesionCount => _estimatedLesionCount;

  SeverityProvider() {
    _initializeSymptoms();
  }

  void _initializeSymptoms() {
    _symptoms = SeverityCalculator.getDefaultSymptoms();
    notifyListeners();
  }

  void updateSymptom(String symptomName, bool isPresent, {String? notes}) {
    final index = _symptoms.indexWhere((s) => s.name == symptomName);
    if (index != -1) {
      _symptoms[index] = _symptoms[index].copyWith(
        isPresent: isPresent,
        notes: notes,
      );
      notifyListeners();
    }
  }

  void setLesionSeverity(SkinLesionSeverity severity) {
    _lesionSeverity = severity;
    notifyListeners();
  }

  void setMucosalInvolvement(MucosalInvolvement involvement) {
    _mucosalInvolvement = involvement;
    notifyListeners();
  }

  void setEstimatedLesionCount(int count) {
    _estimatedLesionCount = count;
    
    // Auto-set lesion severity based on count
    if (count == 0) {
      _lesionSeverity = SkinLesionSeverity.none;
    } else if (count < 25) {
      _lesionSeverity = SkinLesionSeverity.mild;
    } else if (count <= 100) {
      _lesionSeverity = SkinLesionSeverity.moderate;
    } else if (count <= 250) {
      _lesionSeverity = SkinLesionSeverity.severe;
    } else {
      _lesionSeverity = SkinLesionSeverity.verySevere;
    }
    
    notifyListeners();
  }

  void calculateSeverity() {
    _currentAssessment = SeverityCalculator.calculateSeverity(
      symptoms: _symptoms,
      lesionSeverity: _lesionSeverity,
      mucosalInvolvement: _mucosalInvolvement,
      lesionCount: _estimatedLesionCount,
    );
    notifyListeners();
  }

  void resetAssessment() {
    _initializeSymptoms();
    _lesionSeverity = SkinLesionSeverity.none;
    _mucosalInvolvement = MucosalInvolvement.none;
    _currentAssessment = null;
    _estimatedLesionCount = null;
    notifyListeners();
  }

  // Get symptoms by category
  List<ClinicalSymptom> getSymptomsByCategory(String category) {
    return _symptoms.where((s) => s.category == category).toList();
  }

  // Get all categories
  List<String> get categories {
    return _symptoms.map((s) => s.category).toSet().toList()..sort();
  }

  // Quick assessment from detection
  void quickAssessFromDetection(String condition, int estimatedLesions) {
    resetAssessment();
    
    if (condition == 'Monkeypox') {
      // Set common monkeypox symptoms
      updateSymptom('Fever >38°C', true);
      updateSymptom('Lymphadenopathy', true);
      updateSymptom('Myalgia (Muscle pain)', true);
      
      setEstimatedLesionCount(estimatedLesions);
      calculateSeverity();
    }
  }
}
