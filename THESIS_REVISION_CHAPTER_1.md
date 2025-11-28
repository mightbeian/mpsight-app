# MPSight: Comprehensive Multi-Modal Mpox Detection and Severity Assessment System

## COMPLETE THESIS REVISION - Based on Proposal Defense Feedback

---

# CHAPTER I: INTRODUCTION

## 1.1 PROJECT CONTEXT

Infectious diseases continue to challenge global health systems, with emerging viral infections like mpox (formerly monkeypox) requiring rapid, accurate diagnosis and severity assessment to prevent transmission and ensure appropriate treatment. The 2022 mpox outbreak, declared a Public Health Emergency of International Concern (PHEIC) by the World Health Organization, affected over 98,000 cases across more than 100 countries, with 94,623 cases occurring in historically non-endemic regions. The Philippines reported its first confirmed case on July 26, 2022—a travel-related infection from the B.1.3 lineage of Clade IIb associated with the European outbreak.

Traditional diagnostic approaches rely heavily on polymerase chain reaction (PCR) testing, which faces significant limitations including false negative rates up to 40%, high costs, limited availability in resource-constrained settings, and delays in result delivery. Visual diagnosis by dermatologists remains challenging due to mpox's high visual similarity to other exanthematous diseases including chickenpox, measles, cowpox, and hand-foot-mouth disease (HFMD). In the Philippines, the archipelagic geography and uneven distribution of healthcare resources create substantial barriers to timely diagnosis, with many facilities lacking access to dermatological specialists and laboratory diagnostic capabilities.

The emergence of computer vision, deep learning, and multimodal artificial intelligence has created unprecedented opportunities for comprehensive medical diagnostic systems. Recent advances in transformer-based architectures, semantic segmentation networks, and multimodal fusion techniques offer the potential to augment clinical expertise, standardize severity assessment, and improve healthcare accessibility—particularly critical in resource-limited environments where specialist consultation and laboratory testing are unavailable or delayed.

## 1.2 PURPOSE AND DESCRIPTION

MPSight is a comprehensive, multi-modal artificial intelligence system designed for mpox detection, lesion characterization, and severity assessment. The system integrates multiple advanced AI components to provide clinicians with detailed diagnostic support:

### Core System Components

**1. Multi-Class Lesion Type Classification**
- Identifies specific lesion stages: macular, papular, vesicular, pustular, crusted
- Enables progression tracking and treatment monitoring
- Implements YOLOv8 architecture for real-time detection

**2. Multi-Label Disease Classification**
- Simultaneous detection of multiple skin conditions: Mpox, Chickenpox, Measles, Cowpox, HFMD, Healthy skin
- Accounts for co-infection scenarios and diagnostic uncertainty
- Provides comparative confidence scores across all conditions

**3. Lesion Segmentation**
- Pixel-level identification and delineation of individual lesions
- Precise lesion boundary detection for accurate counting and measurement
- Enables automated confluence assessment and distribution mapping
- Implements U-Net architecture with attention mechanisms

**4. Severity Scoring System**
- Automated MPOX-SSS (Mpox Severity Scoring System) calculation
- Integrates: lesion count, regional distribution, confluence, mucosal involvement
- Incorporates dermatologist ratings as ground truth for model training
- Provides standardized severity classification: mild, moderate, severe

**5. Fitzpatrick Skin Type Assessment**
- Evaluates model performance across Fitzpatrick types I-VI
- Addresses potential algorithmic bias in skin type representation
- Ensures equitable diagnostic accuracy across diverse populations
- Implements separate evaluation metrics per skin type

**6. Multimodal Integration**
- Patient symptom assessment (fever, malaise, lymphadenopathy)
- Clinical text notes and medical history
- Metadata integration (lesion location, onset timing, progression)
- Contact tracing information and exposure history

**7. Privacy-Preserving Architecture**
- On-device processing with edge AI deployment
- Encrypted data transmission and secure storage
- HIPAA/GDPR-compliant data handling
- De-identification and anonymization protocols

### System Architecture

The MPSight mobile application provides:
- Real-time camera-based lesion scanning
- Multi-image upload for comprehensive patient assessment
- Interactive segmentation visualization
- Severity score dashboard with clinical recommendations
- Patient history tracking and progression monitoring
- Secure encrypted communication with healthcare providers

## 1.3 DATASET SPECIFICATION

### Primary Dataset: MSLD v2.0 (Mpox Skin Lesion Dataset Version 2.0)

**Source**: Kaggle - https://www.kaggle.com/datasets/joydippaul/mpox-skin-lesion-dataset-version-20-msld-v20/data

**Dataset Characteristics**:
- **Total Images**: 755 original skin lesion images
- **Unique Patients**: 541 patients
- **Verification**: Dermatologist-verified and regulatory-approved
- **Validation Structure**: 5-fold cross-validation splits
- **Augmentation**: Includes augmented versions (rotation, translation, reflection, shear, color jitter, noise, scaling)

**Class Distribution**:
| Class | Original Images | Patients | Percentage |
|-------|----------------|----------|------------|
| Mpox | 284 | - | 37.6% |
| Chickenpox | 75 | - | 9.9% |
| Measles | 55 | - | 7.3% |
| Cowpox | 66 | - | 8.7% |
| HFMD | 161 | - | 21.3% |
| Healthy | 114 | - | 15.1% |

**Dataset Strengths**:
1. Diverse demographic representation (Black, White, Latino, Asian ethnicities)
2. Multiple Fitzpatrick skin types represented
3. Professional dermatologist verification via two-fold process
4. Reverse image search validation for source authenticity
5. Multiple anatomical locations captured
6. Various lesion stages documented

### Supplementary Datasets

**1. MSID (Monkeypox Skin Images Dataset)**
- Source: Mendeley Data v6
- Additional validation images
- Cross-dataset evaluation

**2. Mpox Close Skin Images (MCSI)**
- Source: Kaggle
- High-resolution smartphone-acquired images
- Real-world teledermatology scenarios
- 228 images (102 Mpox-positive, 126 non-Mpox)

**3. Philippine Clinical Dataset (Local Collection)**
- Prospective collection from partner hospitals
- IRB-approved with informed consent
- Focus on Southeast Asian brown skin representation
- Dermatologist-annotated with severity scores
- Estimated 200-300 images (pending IRB approval)

### Lesion Type Annotation Strategy

For multi-class lesion type classification, the research team will:
1. Engage dermatologists to re-annotate MSLD v2.0 images with lesion stage labels
2. Create bounding boxes for each lesion with type classification
3. Generate segmentation masks for precise lesion boundaries
4. Assign MPOX-SSS scores based on clinical criteria
5. Document Fitzpatrick skin type for each patient

## 1.4 RESEARCH QUESTIONS

1. How can deep learning architectures (YOLOv8, U-Net) be optimized for multi-class lesion type detection and pixel-level segmentation across diverse Fitzpatrick skin types?

2. What multi-label classification strategies effectively identify co-occurring skin conditions while maintaining high specificity for mpox detection?

3. How can lesion segmentation models accurately delineate lesion boundaries to enable automated confluence detection and distribution mapping for severity scoring?

4. To what extent can automated MPOX-SSS scoring, trained on dermatologist ground truth ratings, achieve concordance with expert clinical assessment?

5. How does model performance vary across Fitzpatrick skin types (I-VI), and what techniques can mitigate algorithmic bias in underrepresented groups?

6. What multimodal fusion architectures effectively integrate visual features with patient symptoms, text notes, and metadata to improve diagnostic accuracy?

7. How can privacy-preserving techniques (federated learning, differential privacy, secure enclaves) be implemented while maintaining diagnostic performance?

## 1.5 HYPOTHESIS

**H1**: A multi-task deep learning architecture combining YOLOv8 (lesion detection), U-Net (segmentation), and transformer-based fusion will achieve ≥92% accuracy for mpox classification and ≥0.85 Dice coefficient for lesion segmentation on MSLD v2.0.

**H2**: Multi-label classification using binary cross-entropy loss will outperform single-label softmax classification, achieving ≥88% average precision across all six disease classes.

**H3**: Automated MPOX-SSS scoring will demonstrate substantial agreement (Cohen's kappa ≥0.75) with dermatologist severity assessments on validation sets.

**H4**: Model performance stratified by Fitzpatrick skin type will show <5% accuracy variance across types I-VI when balanced sampling and data augmentation strategies are employed.

**H5**: Multimodal integration of images, symptoms, and metadata will improve mpox detection accuracy by ≥7% compared to image-only models (baseline 85% → multimodal 92%).

**H6**: Privacy-preserving on-device inference will achieve <3-second latency per image while maintaining ≥90% of cloud-based model accuracy.

## 1.6 RESEARCH OBJECTIVES

### 1.6.1 GENERAL OBJECTIVE

To develop, implement, and validate MPSight—a comprehensive, privacy-preserving, multi-modal AI system for mpox detection, lesion characterization, and severity assessment that demonstrates equitable performance across diverse Fitzpatrick skin types and integrates seamlessly into clinical workflows.

### 1.6.2 SPECIFIC OBJECTIVES

**Technical Development Objectives**:

1. Design and train a YOLOv8-based multi-class lesion type detector achieving ≥90% mAP@0.5 for five lesion stages (macular, papular, vesicular, pustular, crusted).

2. Implement a U-Net architecture with attention mechanisms for lesion segmentation achieving ≥0.85 Dice coefficient and ≥0.80 Intersection over Union (IoU).

3. Develop a multi-label classification system using MSLD v2.0 dataset, achieving ≥85% average precision across six disease classes.

4. Create an automated MPOX-SSS scoring pipeline integrating lesion count, distribution, confluence, and mucosal involvement assessments.

5. Implement Fitzpatrick skin type classification and establish per-type evaluation metrics demonstrating <5% performance variance.

6. Design a multimodal fusion architecture integrating visual, textual, and metadata features using attention-based mechanisms.

7. Deploy privacy-preserving on-device inference using TensorFlow Lite with INT8 quantization, achieving <20MB model size and <3s latency.

**Clinical Validation Objectives**:

8. Conduct expert validation with ≥3 dermatologists, measuring inter-rater reliability (Cohen's kappa) and system concordance.

9. Collect and annotate ≥200 Philippine clinical images with IRB approval, focusing on Southeast Asian skin representation.

10. Perform prospective clinical validation in ≥2 Philippine healthcare facilities, measuring diagnostic accuracy, time-to-diagnosis, and clinician satisfaction.

**System Integration Objectives**:

11. Develop a Flutter-based mobile application supporting all system components with intuitive clinical workflows.

12. Implement secure, encrypted patient data management complying with HIPAA/GDPR standards and Philippine Data Privacy Act.

13. Create visualization tools for segmentation results, severity scores, and diagnostic explanations (explainable AI).

14. Establish system integration protocols for electronic health records (EHR) and telemedicine platforms.

---

**[Continue to next artifact for complete Chapter revisions...]**
