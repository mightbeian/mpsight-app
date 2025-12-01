# MPSight System Architecture

## Overview

MPSight is a comprehensive, multi-modal artificial intelligence system designed for mpox detection, lesion characterization, and severity assessment. This document describes the technical architecture and integration of all system components.

## AI Components

### 1. Multi-Class Lesion Type Classification

**Purpose:** Identify specific lesion developmental stages for progression tracking.

**Model Architecture:** YOLOv8-based classifier

**Classes:**
- Macular (flat, discolored patches)
- Papular (raised, solid bumps)
- Vesicular (fluid-filled blisters)
- Pustular (pus-filled lesions)
- Crusted (dried, scabbed lesions)

**Input:** 640x640x3 RGB image
**Output:** 5-class probability distribution

```dart
class LesionTypeResult {
  final LesionStage primaryStage;
  final Map<LesionStage, double> stageConfidences;
  final DateTime timestamp;
}
```

### 2. Multi-Label Disease Classification

**Purpose:** Simultaneous detection of multiple skin conditions, supporting co-infection scenarios.

**Model Architecture:** Multi-label CNN with sigmoid activation

**Conditions:**
- Mpox (Monkeypox)
- Chickenpox (Varicella)
- Measles (Rubeola)
- Cowpox
- HFMD (Hand, Foot & Mouth Disease)
- Healthy Skin

**Key Features:**
- Co-infection detection
- Diagnostic uncertainty quantification
- Comparative confidence scoring

```dart
class MultiLabelClassificationResult {
  final Map<SkinCondition, double> confidences;
  final List<SkinCondition> detectedConditions;
  final bool possibleCoInfection;
  final bool highUncertainty;
}
```

### 3. Lesion Segmentation (U-Net with Attention)

**Purpose:** Pixel-level identification and delineation for accurate lesion counting and measurement.

**Model Architecture:** U-Net with attention mechanisms

**Capabilities:**
- Pixel-level segmentation masks
- Precise boundary detection
- Automated confluence assessment
- Distribution mapping
- Lesion counting

**Output Metrics:**
- Individual lesion bounding boxes
- Area measurements (pixels and percentage)
- Circularity scores
- Centroid coordinates
- Confluence grouping

```dart
class SegmentedLesion {
  final Rect boundingBox;
  final int areaPixels;
  final double areaPercentage;
  final Offset centroid;
  final double perimeter;
  final double circularity;
  final double confidence;
}
```

### 4. MPOX-SSS (Mpox Severity Scoring System)

**Purpose:** Automated severity assessment with standardized clinical scoring.

**Scoring Components (0-100 total):**

| Component | Max Points | Criteria |
|-----------|------------|----------|
| Lesion Count | 25 | Number of detected lesions |
| Distribution | 25 | Number of body regions affected |
| Confluence | 25 | Percentage of overlapping lesions |
| Mucosal Involvement | 25 | Presence of oral/genital lesions |

**Severity Levels:**
- **Mild (0-33):** Outpatient management
- **Moderate (34-66):** Consider antiviral therapy
- **Severe (67-100):** Immediate medical attention

**Ground Truth Integration:**
Dermatologist ratings are incorporated as ground truth for model training, including:
- Board certification status
- Years of experience
- Inter-rater agreement scores

```dart
class DermatologistRating {
  final String raterIdHash;
  final SeverityLevel assignedSeverity;
  final int overallScore;
  final Map<String, int> componentScores;
  final int yearsExperience;
  final bool isBoardCertified;
}
```

### 5. Fitzpatrick Skin Type Classification

**Purpose:** Evaluate model fairness across diverse skin tones.

**Classification Types:**
- Type I: Very fair, always burns
- Type II: Fair, usually burns
- Type III: Medium, sometimes burns
- Type IV: Olive, rarely burns
- Type V: Brown, very rarely burns
- Type VI: Dark brown/black, never burns

**Bias Evaluation Metrics:**
- Per-type accuracy
- Demographic parity score
- Equalized odds score
- Maximum accuracy disparity
- False positive/negative rates by type

```dart
class BiasEvaluationReport {
  final Map<FitzpatrickType, FitzpatrickPerformanceMetrics> metricsByType;
  final double overallAccuracy;
  final double maxAccuracyDisparity;
  final double demographicParityScore;
  final bool passesEquityCheck;
}
```

## Multimodal Integration

### Patient Data Components

1. **Symptom Assessment**
   - Fever and temperature
   - Malaise/fatigue
   - Lymphadenopathy with locations
   - Headache, myalgia, sore throat
   - Symptom duration

2. **Lesion Metadata**
   - Location on body
   - Onset date
   - Progression notes
   - Pain and itching levels
   - Outbreak history

3. **Exposure History**
   - Known exposure status
   - Travel history
   - Healthcare worker status
   - Animal contact
   - Contact tracing data

4. **Clinical Notes**
   - Free-text observations
   - Structured assessments
   - Treatment plans

## Privacy-Preserving Architecture

### Core Principles

1. **On-Device Processing**
   - All AI inference runs locally
   - No image data transmitted externally
   - Edge AI deployment ready

2. **Data Anonymization**
   - SHA-256 hashing of identifiers
   - Age generalization to groups
   - Date truncation
   - Direct identifier removal

3. **Encryption**
   - AES-256-GCM for data at rest
   - TLS 1.3 for any transmission
   - Secure key management

4. **Compliance**
   - HIPAA audit logging
   - GDPR consent management
   - Data retention policies
   - Right to deletion support

### Consent Management

```dart
enum ConsentPurpose {
  diagnosticAnalysis,
  dataStorage,
  researchUse,
  modelImprovement,
  anonymizedAggregation,
}

class ConsentRecord {
  final String consentId;
  final List<ConsentPurpose> purposes;
  final bool isActive;
  final DateTime? withdrawalDate;
}
```

### Audit Logging

All data access and processing is logged:

```dart
enum AuditAction {
  dataAccess,
  dataCreate,
  dataUpdate,
  dataDelete,
  dataExport,
  modelInference,
  consentGrant,
  consentWithdraw,
}
```

## Data Flow

```
User Input
    │
    ▼
┌─────────────────┐
│ Consent Check  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Image Capture  │───────────────┐
└────────┬────────┘               │
         │                       │
         ▼                       ▼
┌─────────────────┐      ┌─────────────────┐
│ Preprocessing  │      │ Patient Data   │
└────────┬────────┘      └────────┬────────┘
         │                       │
         ▼                       │
┌───────────────────────────────┐
│      PARALLEL AI PIPELINE      │
├─────────┬─────────┬──────────┤
│ Lesion  │ Disease │ Segment  │
│ Type    │ Class   │ -ation   │
└────┬────┴────┬────┴────┬─────┘
     │         │         │
     └─────────┼─────────┘
               │
               ▼
┌─────────────────┐◄─────────┘
│ Severity      │ (Patient Data)
│ Scoring       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Results &     │
│ Recommendations│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Audit Log     │
└─────────────────┘
```

## Model Training Pipeline

### Dataset Requirements

1. **Images**: Annotated skin lesion images with:
   - Disease labels (multi-label)
   - Lesion stage labels
   - Segmentation masks
   - Fitzpatrick type annotations

2. **Clinical Data**:
   - Dermatologist severity ratings
   - Patient symptoms
   - Outcome data

### Training Ground Truth

Dermatologist ratings incorporate:
- Multiple independent ratings per case
- Inter-rater reliability metrics
- Weighted consensus based on experience
- Board certification consideration

## Performance Metrics

### Disease Classification
- Sensitivity/Specificity per condition
- Multi-label accuracy (exact match)
- Hamming loss
- F1 score (micro/macro)

### Segmentation
- Dice coefficient
- IoU (Intersection over Union)
- Pixel-wise accuracy
- Boundary F1 score

### Severity Scoring
- MAE vs dermatologist consensus
- Classification accuracy (Mild/Moderate/Severe)
- Cohen's kappa agreement

### Fairness (Fitzpatrick)
- Accuracy disparity across types
- False positive rate parity
- False negative rate parity
- Equalized odds

## Future Enhancements

1. **Federated Learning**: Privacy-preserving model improvement across institutions
2. **Temporal Analysis**: Tracking lesion progression over time
3. **Multi-language Support**: Clinical notes in multiple languages
4. **Integration APIs**: HL7 FHIR compatibility for EHR systems
5. **Explainability**: Grad-CAM visualization for model decisions
