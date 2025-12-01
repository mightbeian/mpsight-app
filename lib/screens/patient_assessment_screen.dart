/// Patient Assessment Screen
/// Multimodal data collection for comprehensive analysis

import 'package:flutter/material.dart';
import '../models/patient_data.dart';
import '../models/fitzpatrick_type.dart';
import '../models/segmentation_result.dart';

class PatientAssessmentScreen extends StatefulWidget {
  final Function(PatientAssessment) onAssessmentComplete;

  const PatientAssessmentScreen({
    super.key,
    required this.onAssessmentComplete,
  });

  @override
  State<PatientAssessmentScreen> createState() =>
      _PatientAssessmentScreenState();
}

class _PatientAssessmentScreenState extends State<PatientAssessmentScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Symptom Assessment
  bool _hasFever = false;
  double? _temperature;
  bool _hasMalaise = false;
  bool _hasLymphadenopathy = false;
  List<LymphadenopathyLocation> _lymphLocations = [];
  bool _hasHeadache = false;
  bool _hasMyalgia = false;
  bool _hasSoreThroat = false;
  bool _hasPharyngitis = false;
  bool _hasChills = false;
  bool _hasNausea = false;
  int? _symptomDurationDays;

  // Lesion Metadata
  BodyRegion? _lesionLocation;
  DateTime? _onsetDate;
  bool _isFirstOutbreak = true;
  int? _previousOutbreakCount;
  bool _hasPain = false;
  int _painLevel = 0;
  bool _hasItching = false;
  int _itchingLevel = 0;
  final _progressionNotesController = TextEditingController();

  // Exposure History
  bool _hasKnownExposure = false;
  DateTime? _exposureDate;
  String? _exposureContext;
  bool _hasRecentTravel = false;
  List<String> _travelLocations = [];
  bool _isHealthcareWorker = false;
  bool _hasAnimalContact = false;
  String? _animalType;
  bool _hasSexualExposureRisk = false;

  // Patient Info
  int? _ageGroup;
  String? _genderCode;
  bool _hasImmunocompromise = false;
  bool _isPregnant = false;
  bool _hasHIV = false;
  List<String> _comorbidities = [];

  // Clinical Notes
  final _clinicalNotesController = TextEditingController();

  @override
  void dispose() {
    _progressionNotesController.dispose();
    _clinicalNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Assessment'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
          onStepTapped: (step) => setState(() => _currentStep = step),
          steps: [
            _buildSymptomStep(),
            _buildLesionMetadataStep(),
            _buildExposureStep(),
            _buildPatientInfoStep(),
            _buildClinicalNotesStep(),
          ],
        ),
      ),
    );
  }

  Step _buildSymptomStep() {
    return Step(
      title: const Text('Symptoms'),
      subtitle: const Text('Current symptom assessment'),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text('Fever'),
            value: _hasFever,
            onChanged: (v) => setState(() => _hasFever = v),
          ),
          if (_hasFever)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Temperature (°C)',
                  hintText: 'e.g., 38.5',
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => _temperature = double.tryParse(v),
              ),
            ),
          SwitchListTile(
            title: const Text('Malaise / Fatigue'),
            value: _hasMalaise,
            onChanged: (v) => setState(() => _hasMalaise = v),
          ),
          SwitchListTile(
            title: const Text('Lymphadenopathy'),
            subtitle: const Text('Swollen lymph nodes'),
            value: _hasLymphadenopathy,
            onChanged: (v) => setState(() => _hasLymphadenopathy = v),
          ),
          if (_hasLymphadenopathy)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                children: LymphadenopathyLocation.values.map((loc) {
                  return FilterChip(
                    label: Text(loc.name),
                    selected: _lymphLocations.contains(loc),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _lymphLocations.add(loc);
                        } else {
                          _lymphLocations.remove(loc);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          SwitchListTile(
            title: const Text('Headache'),
            value: _hasHeadache,
            onChanged: (v) => setState(() => _hasHeadache = v),
          ),
          SwitchListTile(
            title: const Text('Muscle Pain (Myalgia)'),
            value: _hasMyalgia,
            onChanged: (v) => setState(() => _hasMyalgia = v),
          ),
          SwitchListTile(
            title: const Text('Sore Throat'),
            value: _hasSoreThroat,
            onChanged: (v) => setState(() => _hasSoreThroat = v),
          ),
          SwitchListTile(
            title: const Text('Chills'),
            value: _hasChills,
            onChanged: (v) => setState(() => _hasChills = v),
          ),
          SwitchListTile(
            title: const Text('Nausea'),
            value: _hasNausea,
            onChanged: (v) => setState(() => _hasNausea = v),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Symptom Duration (days)',
                hintText: 'How many days since symptoms started?',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => _symptomDurationDays = int.tryParse(v),
            ),
          ),
        ],
      ),
    );
  }

  Step _buildLesionMetadataStep() {
    return Step(
      title: const Text('Lesion Information'),
      subtitle: const Text('Details about the skin lesions'),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<BodyRegion>(
              decoration: const InputDecoration(
                labelText: 'Primary Lesion Location',
              ),
              value: _lesionLocation,
              items: BodyRegion.values
                  .where((r) => r != BodyRegion.unknown)
                  .map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(r.displayName),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _lesionLocation = v),
            ),
          ),
          ListTile(
            title: const Text('Onset Date'),
            subtitle: Text(_onsetDate?.toString().split(' ')[0] ?? 'Not set'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 60)),
                lastDate: DateTime.now(),
              );
              if (date != null) setState(() => _onsetDate = date);
            },
          ),
          SwitchListTile(
            title: const Text('First Outbreak'),
            subtitle: const Text('Is this the first time experiencing this?'),
            value: _isFirstOutbreak,
            onChanged: (v) => setState(() => _isFirstOutbreak = v),
          ),
          if (!_isFirstOutbreak)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Number of Previous Outbreaks',
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => _previousOutbreakCount = int.tryParse(v),
              ),
            ),
          SwitchListTile(
            title: const Text('Pain'),
            value: _hasPain,
            onChanged: (v) => setState(() => _hasPain = v),
          ),
          if (_hasPain)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pain Level: $_painLevel'),
                  Slider(
                    value: _painLevel.toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: _painLevel.toString(),
                    onChanged: (v) => setState(() => _painLevel = v.round()),
                  ),
                ],
              ),
            ),
          SwitchListTile(
            title: const Text('Itching'),
            value: _hasItching,
            onChanged: (v) => setState(() => _hasItching = v),
          ),
          if (_hasItching)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Itching Level: $_itchingLevel'),
                  Slider(
                    value: _itchingLevel.toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: _itchingLevel.toString(),
                    onChanged: (v) =>
                        setState(() => _itchingLevel = v.round()),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              controller: _progressionNotesController,
              decoration: const InputDecoration(
                labelText: 'Progression Notes',
                hintText: 'Describe how the lesions have changed over time',
              ),
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  Step _buildExposureStep() {
    return Step(
      title: const Text('Exposure History'),
      subtitle: const Text('Contact tracing information'),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      content: Column(
        children: [
          SwitchListTile(
            title: const Text('Known Exposure'),
            subtitle: const Text('Contact with confirmed/suspected case'),
            value: _hasKnownExposure,
            onChanged: (v) => setState(() => _hasKnownExposure = v),
          ),
          if (_hasKnownExposure) ...[
            ListTile(
              title: const Text('Exposure Date'),
              subtitle:
                  Text(_exposureDate?.toString().split(' ')[0] ?? 'Not set'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate:
                      DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _exposureDate = date);
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Exposure Context',
                ),
                value: _exposureContext,
                items: const [
                  DropdownMenuItem(value: 'household', child: Text('Household')),
                  DropdownMenuItem(value: 'healthcare', child: Text('Healthcare')),
                  DropdownMenuItem(value: 'travel', child: Text('Travel')),
                  DropdownMenuItem(value: 'social', child: Text('Social Contact')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _exposureContext = v),
              ),
            ),
          ],
          SwitchListTile(
            title: const Text('Recent Travel'),
            subtitle: const Text('International or endemic area travel'),
            value: _hasRecentTravel,
            onChanged: (v) => setState(() => _hasRecentTravel = v),
          ),
          SwitchListTile(
            title: const Text('Healthcare Worker'),
            value: _isHealthcareWorker,
            onChanged: (v) => setState(() => _isHealthcareWorker = v),
          ),
          SwitchListTile(
            title: const Text('Animal Contact'),
            subtitle: const Text('Contact with rodents or primates'),
            value: _hasAnimalContact,
            onChanged: (v) => setState(() => _hasAnimalContact = v),
          ),
          SwitchListTile(
            title: const Text('Sexual Exposure Risk'),
            value: _hasSexualExposureRisk,
            onChanged: (v) => setState(() => _hasSexualExposureRisk = v),
          ),
        ],
      ),
    );
  }

  Step _buildPatientInfoStep() {
    return Step(
      title: const Text('Patient Information'),
      subtitle: const Text('Demographics and medical history'),
      isActive: _currentStep >= 3,
      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Age Group',
              ),
              value: _ageGroup,
              items: const [
                DropdownMenuItem(value: 0, child: Text('Under 18')),
                DropdownMenuItem(value: 1, child: Text('18-34')),
                DropdownMenuItem(value: 2, child: Text('35-49')),
                DropdownMenuItem(value: 3, child: Text('50-64')),
                DropdownMenuItem(value: 4, child: Text('65+')),
              ],
              onChanged: (v) => setState(() => _ageGroup = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Gender',
              ),
              value: _genderCode,
              items: const [
                DropdownMenuItem(value: 'M', child: Text('Male')),
                DropdownMenuItem(value: 'F', child: Text('Female')),
                DropdownMenuItem(value: 'O', child: Text('Other')),
                DropdownMenuItem(value: 'U', child: Text('Prefer not to say')),
              ],
              onChanged: (v) => setState(() => _genderCode = v),
            ),
          ),
          SwitchListTile(
            title: const Text('Immunocompromised'),
            value: _hasImmunocompromise,
            onChanged: (v) => setState(() => _hasImmunocompromise = v),
          ),
          SwitchListTile(
            title: const Text('Pregnant'),
            value: _isPregnant,
            onChanged: (v) => setState(() => _isPregnant = v),
          ),
          SwitchListTile(
            title: const Text('HIV Positive'),
            value: _hasHIV,
            onChanged: (v) => setState(() => _hasHIV = v),
          ),
        ],
      ),
    );
  }

  Step _buildClinicalNotesStep() {
    return Step(
      title: const Text('Clinical Notes'),
      subtitle: const Text('Additional observations'),
      isActive: _currentStep >= 4,
      state: StepState.indexed,
      content: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              controller: _clinicalNotesController,
              decoration: const InputDecoration(
                labelText: 'Clinical Notes',
                hintText: 'Enter any additional clinical observations...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _submitAssessment,
            icon: const Icon(Icons.check),
            label: const Text('Complete Assessment'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onStepContinue() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      _submitAssessment();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _submitAssessment() {
    final symptoms = SymptomAssessment(
      hasFever: _hasFever,
      temperature: _temperature,
      hasMalaise: _hasMalaise,
      hasLymphadenopathy: _hasLymphadenopathy,
      lymphLocations: _lymphLocations.isNotEmpty ? _lymphLocations : null,
      hasHeadache: _hasHeadache,
      hasMyalgia: _hasMyalgia,
      hasSoreThroat: _hasSoreThroat,
      hasPharyngitis: _hasPharyngitis,
      hasChills: _hasChills,
      hasNausea: _hasNausea,
      symptomDurationDays: _symptomDurationDays,
      assessmentDate: DateTime.now(),
    );

    final lesionMetadata = LesionMetadata(
      location: _lesionLocation,
      onsetDate: _onsetDate,
      daysFromOnset: _onsetDate != null
          ? DateTime.now().difference(_onsetDate!).inDays
          : null,
      progressionNotes: _progressionNotesController.text.isNotEmpty
          ? _progressionNotesController.text
          : null,
      isFirstOutbreak: _isFirstOutbreak,
      previousOutbreakCount: _previousOutbreakCount,
      hasPain: _hasPain,
      painLevel: _hasPain ? _painLevel : null,
      hasItching: _hasItching,
      itchingLevel: _hasItching ? _itchingLevel : null,
    );

    final exposureHistory = ExposureHistory(
      hasKnownExposure: _hasKnownExposure,
      exposureDate: _exposureDate,
      exposureContext: _exposureContext,
      hasRecentTravel: _hasRecentTravel,
      travelLocations: _travelLocations.isNotEmpty ? _travelLocations : null,
      isHealthcareWorker: _isHealthcareWorker,
      hasAnimalContact: _hasAnimalContact,
      animalType: _animalType,
      hasSexualExposureRisk: _hasSexualExposureRisk,
      daysSinceExposure: _exposureDate != null
          ? DateTime.now().difference(_exposureDate!).inDays
          : null,
    );

    List<ClinicalNote> notes = [];
    if (_clinicalNotesController.text.isNotEmpty) {
      notes.add(ClinicalNote(
        noteId: 'NOTE_${DateTime.now().millisecondsSinceEpoch}',
        content: _clinicalNotesController.text,
        createdAt: DateTime.now(),
        noteType: NoteType.initialAssessment,
        isStructured: false,
      ));
    }

    final assessment = PatientAssessment(
      assessmentId: 'ASSESS_${DateTime.now().millisecondsSinceEpoch}',
      patientIdHash: 'PATIENT_ANONYMOUS', // Would be set by privacy service
      assessmentDate: DateTime.now(),
      symptoms: symptoms,
      lesionMetadata: lesionMetadata,
      exposureHistory: exposureHistory,
      clinicalNotes: notes,
      ageGroup: _ageGroup,
      genderCode: _genderCode,
      hasImmunocompromise: _hasImmunocompromise,
      isPregnant: _isPregnant,
      hasHIV: _hasHIV,
      comorbidities: _comorbidities.isNotEmpty ? _comorbidities : null,
    );

    widget.onAssessmentComplete(assessment);
    Navigator.of(context).pop();
  }
}
