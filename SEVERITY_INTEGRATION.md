# Mpox Severity Scoring System Integration

## Overview
The WHO Mpox Severity Scoring System (MPOX_SSS) has been fully integrated into the MPSight Flutter app, providing clinical severity assessment and care recommendations based on standardized medical guidelines.

## Features Implemented

### 1. **Severity Assessment Model** (`lib/models/severity_assessment.dart`)
Comprehensive data structures for clinical assessment:

- **Severity Levels**: Mild, Moderate, Severe, Critical
- **Skin Lesion Classification**:
  - None (0 lesions)
  - Mild (<25 lesions)
  - Moderate (25-100 lesions)
  - Severe (101-250 lesions)
  - Very Severe (>250 lesions)

- **Mucosal Involvement Tracking**:
  - None
  - Mild (1 site)
  - Moderate (2 sites)
  - Severe (≥3 sites or extensive)

- **Clinical Symptoms** (24 total) organized by category:
  - **Constitutional** (5 symptoms): Fever, fatigue, myalgia, headache, lymphadenopathy
  - **Respiratory** (4 symptoms): Cough, sore throat, difficulty breathing, chest pain
  - **Gastrointestinal** (4 symptoms): Nausea/vomiting, diarrhea, abdominal pain, dehydration
  - **Neurological** (3 symptoms): Confusion, seizures, severe headache
  - **Dermatological** (4 symptoms): Secondary infection, severe pain, bleeding, necrosis
  - **Ocular** (4 symptoms): Eye pain, photophobia, vision changes, corneal lesions

### 2. **Severity Calculator** (`lib/models/severity_assessment.dart`)
Intelligent scoring algorithm:

- **Symptom Scoring**: Each symptom has weighted scores (1-5 points) based on clinical severity
- **Lesion Scoring**: Automatic scoring based on lesion count (2-8 points)
- **Mucosal Scoring**: Progressive scoring for affected sites (2-6 points)
- **Total Score Calculation**: Combined symptom, lesion, and mucosal scores
- **Severity Determination**:
  - Mild: 0-7 points
  - Moderate: 8-14 points
  - Severe: 15-24 points
  - Critical: ≥25 points OR presence of critical symptoms

- **Smart Recommendations**: Context-aware care suggestions based on:
  - Overall severity level
  - Specific symptoms present
  - Lesion distribution
  - Mucosal involvement

### 3. **Severity Provider** (`lib/providers/severity_provider.dart`)
State management for assessment workflow:

- Symptom tracking and modification
- Automatic lesion severity calculation from count
- Real-time severity recalculation
- Quick assessment from detection results
- Assessment history management

### 4. **Severity Assessment Screen** (`lib/screens/severity_assessment_screen.dart`)
Full-featured UI for clinical assessment:

**Assessment Form**:
- Lesion count input with automatic severity classification
- Mucosal involvement selection with chip buttons
- Expandable symptom categories with checkboxes
- Score preview for each symptom

**Results Display**:
- Large, color-coded severity card with total score
- Urgency indicators for hospitalization/ICU needs
- Score breakdown by category
- Detailed care recommendations list
- Medical disclaimer

**Design Features**:
- Material 3 design with color-coded severity levels:
  - Green (Mild)
  - Orange (Moderate)
  - Deep Orange (Severe)
  - Red (Critical)
- Responsive layout with cards and expansion tiles
- Emergency icons for urgent cases (⚠️, 🚨)
- Reset button for new assessments

### 5. **Quick Access Widget** (`lib/widgets/severity_quick_access.dart`)
One-tap severity assessment from detection results:

- Appears automatically when Monkeypox is detected
- Pre-fills common symptoms (fever, lymphadenopathy, myalgia)
- Estimates lesion count from image
- Quick navigation to full assessment

### 6. **Integration Points**

**Home Screen**:
- New "Severity Score" card in main action grid
- Red medical icon for high visibility
- Description: "Calculate Mpox severity"

**Camera Screen**:
- Severity quick access appears after detection
- Below confidence chart results
- Shows when Monkeypox detected

**Gallery Screen**:
- Same severity quick access placement
- Integrated with image analysis results

**Main App**:
- SeverityProvider registered in MultiProvider
- Available throughout app lifecycle

## Usage Flow

### Standard Assessment
1. User taps "Severity Score" on home screen
2. Enter estimated lesion count (auto-categorizes severity)
3. Select mucosal involvement level
4. Check applicable symptoms by category
5. Tap "Calculate Severity Score"
6. View comprehensive results and recommendations

### Quick Assessment (from Detection)
1. Upload/capture image with Monkeypox lesions
2. App detects Monkeypox condition
3. "Assess Severity" card appears
4. Tap card for pre-filled assessment
5. Adjust symptoms as needed
6. Get instant severity results

## Clinical Accuracy

### Scoring Methodology
Based on WHO guidelines and clinical severity indicators:

- **High-priority symptoms** (4-5 points):
  - Difficulty breathing
  - Confusion/altered mental status
  - Seizures
  - Vision changes/corneal lesions
  - Bleeding from lesions

- **Moderate-priority symptoms** (2-3 points):
  - Severe fatigue
  - Lymphadenopathy
  - Gastrointestinal symptoms
  - Secondary infections
  - Severe pain

- **Low-priority symptoms** (1 point):
  - Fever
  - Myalgia
  - Headache
  - Cough/sore throat

### Critical Care Triggers
Automatic recommendations for hospitalization when:
- Total score ≥15 (Severe)
- Any symptom with score ≥4 present
- Critical symptoms detected (respiratory distress, neurological changes, vision impairment)

ICU admission recommended when:
- Total score ≥25 (Critical)
- Confusion/altered mental status
- Seizures present
- Difficulty breathing

## Care Recommendations

### Mild Cases
- Home isolation and self-care
- Daily symptom monitoring
- Lesion care (clean and covered)
- Hydration and pain relief
- Avoid contact until healed

### Moderate Cases
- Contact healthcare provider
- Consider outpatient monitoring
- Pain management needed
- Watch for secondary infections
- Monitor for worsening
- Antiviral consultation

### Severe Cases
- ⚠️ SEEK IMMEDIATE MEDICAL ATTENTION
- Hospital admission recommended
- Antiviral therapy (Tecovirimat)
- IV fluids if needed
- Professional wound care
- Isolation precautions

### Critical Cases
- 🚨 EMERGENCY CARE REQUIRED
- Call emergency services
- ICU admission may be needed
- Aggressive supportive care
- Mandatory antiviral therapy
- Vital signs monitoring
- Specialist consultations

## Technical Implementation

### Dependencies
- `provider` package for state management
- Flutter Material 3 design system
- Existing detection providers for integration

### File Structure
```
lib/
├── models/
│   └── severity_assessment.dart      # Data models and calculator
├── providers/
│   └── severity_provider.dart        # State management
├── screens/
│   ├── severity_assessment_screen.dart  # Main UI
│   ├── camera_screen.dart            # Updated with quick access
│   ├── gallery_screen.dart           # Updated with quick access
│   └── home_screen.dart              # Updated with navigation
└── widgets/
    └── severity_quick_access.dart    # Quick assessment widget
```

### Data Flow
```
Detection Results
    ↓
Quick Assessment Widget
    ↓
Severity Provider (pre-filled)
    ↓
Assessment Screen (user input)
    ↓
Severity Calculator
    ↓
Results Display + Recommendations
```

## Future Enhancements

### Planned Features
1. **Assessment History**: Save and track severity over time
2. **Trend Analysis**: Show severity progression charts
3. **Export Reports**: PDF generation for medical records
4. **Symptom Timeline**: Track when symptoms appeared
5. **Photo Documentation**: Link lesion photos to assessments
6. **Multi-language**: Translate recommendations
7. **Telemedicine Integration**: Share results with providers
8. **Risk Stratification**: Additional comorbidity factors

### Advanced Scoring
1. **Age-adjusted scoring**: Pediatric/geriatric modifications
2. **Comorbidity weighting**: HIV, immunocompromised status
3. **Pregnancy considerations**: Special scoring criteria
4. **Vaccination status**: Impact on severity
5. **Previous infection**: Reinfection severity patterns

## Testing Recommendations

### Test Scenarios
1. **Mild case**: 10 lesions, fever only → Should show "Mild"
2. **Moderate case**: 75 lesions, fever, fatigue, nausea → "Moderate"
3. **Severe case**: 200 lesions, multiple symptoms, 2 mucosal sites → "Severe"
4. **Critical case**: Any respiratory distress or confusion → "Critical"

### Integration Tests
1. Monkeypox detection → Quick access appears
2. Other conditions → Quick access hidden
3. Quick assessment pre-fills symptoms correctly
4. Score calculation matches expected values
5. Recommendations match severity level

## Medical Disclaimer
This severity assessment tool is for informational and educational purposes only. It does not constitute medical advice, diagnosis, or treatment. Healthcare decisions should be made in consultation with qualified medical professionals. In case of emergency, call local emergency services immediately.

## Credits
- WHO Mpox Severity Scoring System (MPOX_SSS v9)
- Clinical guidelines from WHO/CDC
- Developed for MPSight v2.0
- Integration by AI Assistant

## Version History
- **v1.0** (Dec 2024): Initial integration
  - 24 clinical symptoms
  - 4 severity levels
  - WHO-based recommendations
  - Quick assessment from detection
  - Full assessment screen
