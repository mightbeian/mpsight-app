# CHAPTER III: RESEARCH METHODOLOGY (Comprehensive Revision)

## 3.1 Research Design

This study employs a **mixed-methods developmental research design** combining:
1. **Quantitative analysis**: Model performance metrics, statistical validation
2. **Qualitative analysis**: Clinical usability assessment, expert feedback
3. **Experimental validation**: Prospective clinical testing in Philippine healthcare settings

The research follows an **Agile iterative development methodology** with continuous integration of clinical feedback, enabling adaptive improvement of system components based on stakeholder input.

## 3.2 Dataset Acquisition and Preparation

### 3.2.1 Primary Dataset: MSLD v2.0

**Source**: Kaggle - https://www.kaggle.com/datasets/joydippaul/mpox-skin-lesion-dataset-version-20-msld-v20/data

**Characteristics**:
- 755 original images from 541 patients
- 6 classes: Mpox (284), Chickenpox (75), Measles (55), Cowpox (66), HFMD (161), Healthy (114)
- Dermatologist-verified via two-fold validation process
- 5-fold cross-validation splits pre-configured
- Augmented versions provided (rotation, translation, reflection, shear, color jitter)

**Dataset Limitations Addressed**:
1. **Missing Lesion Type Labels**: Research team will re-annotate 400-500 images with lesion stage labels (macular, papular, vesicular, pustular, crusted) verified by ≥2 dermatologists
2. **No Segmentation Masks**: Semi-automated annotation using CVAT + SAM (Segment Anything Model) with dermatologist refinement
3. **No Severity Scores**: Clinical team assigns MPOX-SSS scores based on visible lesions and documented clinical parameters

### 3.2.2 Supplementary Datasets

**MSID (Monkeypox Skin Images Dataset v6)**:
- Source: Mendeley Data
- Purpose: Cross-dataset validation
- Images: Variable (supplementary to MSLD v2.0)

**MCSI (Mpox Close Skin Images)**:
- Source: NIAID Data Ecosystem / Kaggle
- Images: 228 (102 Mpox+, 126 Mpox-)
- Purpose: External validation, teledermatology scenario testing
- Characteristics: Smartphone-acquired, high-resolution

**Philippine Clinical Dataset** (Pending IRB):
- Target: 200-300 images from 2-3 partner hospitals
- Focus: Fitzpatrick Types III-VI (Southeast Asian population)
- Annotations: Lesion types, segmentation masks, MPOX-SSS scores, Fitzpatrick classification
- Timeline: IRB submission Month 2, Collection Months 4-8

### 3.2.3 Data Annotation Pipeline

**Phase 1: Lesion Type Annotation** (Months 2-3)
1. Select 400-500 representative images from MSLD v2.0
2. Clinical team annotates each image with:
   - Lesion stage classification (macular/papular/vesicular/pustular/crusted)
   - Bounding boxes for each lesion
   - Confidence level (high/medium/low)
3. Independent verification by ≥2 dermatologists
4. Consensus resolution for disagreements
5. Quality control: 10% re-annotation by third expert

**Phase 2: Segmentation Mask Generation** (Months 3-4)
1. Semi-automated segmentation using SAM (Segment Anything Model)
2. Manual refinement in CVAT annotation tool
3. Quality metrics: Edge smoothness, boundary precision
4. Dermatologist validation of mask accuracy
5. Inter-annotator agreement: Target Dice coefficient ≥0.90

**Phase 3: Severity Score Assignment** (Months 4-5)
1. Dermatologist panel (n=3) independently assigns MPOX-SSS scores
2. Components assessed:
   - Total lesion count (from segmentation masks)
   - Regional distribution (head/neck, trunk, extremities, genitals)
   - Confluence (based on mask overlap analysis)
   - Mucosal involvement (if documented in metadata)
3. Consensus scoring: Majority vote or median value
4. Inter-rater reliability: Calculate Cohen's kappa (target ≥0.70)

**Phase 4: Fitzpatrick Classification** (Month 5)
1. Computational Fitzpatrick classifier applied to all images
2. Dermatologist review and correction of misclassifications
3. Distribution analysis across types I-VI
4. Identify underrepresented types for targeted augmentation

### 3.2.4 Data Splitting Strategy

**Training Set** (70%): ~528 images
- Used for model training and parameter optimization
- Stratified by class to maintain distribution
- Augmentation applied during training

**Validation Set** (15%): ~113 images
- Hyperparameter tuning and model selection
- No augmentation applied
- Used for early stopping criterion

**Test Set** (15%): ~114 images
- Final performance evaluation
- Completely held out, never seen during training
- Stratified by class and Fitzpatrick type
- No augmentation

**5-Fold Cross-Validation**:
- Utilized for robust performance estimation
- Reduces variance in performance metrics
- Enables ensemble model development

### 3.2.5 Data Augmentation Techniques

**Spatial Augmentations**:
- Random rotation: ±20 degrees
- Horizontal/vertical flipping: 50% probability
- Random scaling: 0.8-1.2x
- Elastic deformation: Simulate skin texture variation
- Perspective transformation: ±10 degrees

**Color Augmentations** (Critical for Fitzpatrick diversity):
- Brightness: ±25%
- Contrast: ±25%
- Saturation: ±20%
- Hue shift: ±15 degrees
- Color jitter: Simulate different lighting conditions

**Clinical Augmentations**:
- Gaussian noise: Simulate low-quality cameras (σ=0.01-0.05)
- Motion blur: Simulate camera shake (kernel 3x3-7x7)
- JPEG compression: Simulate compressed teledermatology images (quality 60-95)
- Random shadows: Simulate natural/artificial lighting variations

**Advanced Augmentations**:
- MixUp: Blend two images with different diseases (alpha=0.2)
- CutMix: Replace image regions with patches from other classes
- AugMix: Compositional augmentation for robustness

### 3.2.6 Class Imbalance Mitigation

**Problem**: Mpox (284) >> Measles (55), creating biased learning

**Solutions**:
1. **Weighted Loss Functions**:
   - Class weights inversely proportional to frequency
   - Focal loss (γ=2.0) emphasizing hard examples

2. **Oversampling Minority Classes**:
   - SMOTE-like augmentation for Measles, Chickenpox
   - Target balanced distribution in training batches

3. **Two-Stage Training**:
   - Stage 1: Train on balanced subset
   - Stage 2: Fine-tune on full dataset with weights

## 3.3 Multi-Task Architecture Design

### 3.3.1 System Architecture Overview

MPSight employs a **multi-task learning architecture** with shared backbone and task-specific heads:

```
Input Image (640x640x3)
         ↓
[Shared Backbone: EfficientNet-B4]
         ↓
   Feature Maps (20x20x512)
         ↓
    ┌────┴────┬─────────┬──────────┐
    ↓         ↓         ↓          ↓
[Lesion    [Lesion  [Multi-Label [Severity
Detection  Segment  Disease      Scoring
Head]      Head]    Classification] Module]
    ↓         ↓         ↓          ↓
Bounding  Pixel-level 6-class    MPOX-SSS
Boxes +   Masks +     Probabilities Score
Types     Areas                    0-18+
```

### 3.3.2 Task 1: Multi-Class Lesion Type Detection (YOLOv8)

**Architecture**: YOLOv8m (medium variant)
- Parameters: 25.9M
- Input: 640x640x3 RGB image
- Output: [N, 6] tensor (N lesions × [x, y, w, h, confidence, class])
- Classes: macular, papular, vesicular, pustular, crusted, background

**Training Configuration**:
```yaml
Model: YOLOv8m
Epochs: 200
Batch Size: 16
Optimizer: AdamW (lr=0.001, weight_decay=0.0005)
LR Schedule: Cosine annealing with warm restart
Augmentation: Mosaic, MixUp, HSV augmentation
Loss: CIoU + Binary Cross-Entropy (multi-label)
IoU Threshold: 0.5
Confidence Threshold: 0.25
NMS IoU Threshold: 0.7
```

**Performance Metrics**:
- Mean Average Precision (mAP@0.5, mAP@0.5:0.95)
- Per-class Precision and Recall
- F1-Score for each lesion type
- Inference time (ms per image)

### 3.3.3 Task 2: Lesion Segmentation (U-Net + Attention)

**Architecture**: U-Net with Squeeze-and-Excitation (SE) attention blocks
- Encoder: EfficientNet-B4 (pretrained on ImageNet)
- Decoder: 4 upsampling blocks with skip connections
- Attention: SE blocks in each decoder level
- Output: Binary mask (640x640x1) per lesion

**Training Configuration**:
```yaml
Model: U-Net + SE-Attention
Encoder: EfficientNet-B4 (pretrained)
Epochs: 150
Batch Size: 8
Optimizer: AdamW (lr=0.0001)
LR Schedule: ReduceLROnPlateau (patience=10)
Loss: Dice Loss + Binary Cross-Entropy (α=0.5)
Augmentation: Spatial + Color (same as detection)
Early Stopping: Patience=20 epochs
```

**Performance Metrics**:
- Dice Coefficient (per lesion, averaged)
- Intersection over Union (IoU)
- Pixel-wise Accuracy
- Boundary F1-Score (edge detection quality)
- Hausdorff Distance (boundary deviation)

### 3.3.4 Task 3: Multi-Label Disease Classification

**Architecture**: Multi-label head with independent sigmoid outputs
- Input: Global features from backbone (1x1x512)
- Hidden layers: Dense(256) → ReLU → Dropout(0.3) → Dense(6)
- Output: 6 independent probabilities [0,1] for each disease

**Training Configuration**:
```yaml
Loss: Binary Cross-Entropy (multi-label)
Threshold: 0.5 per class (adjustable per class)
Class Weights: Inverse frequency weighting
Positive Class Weight: 2.0 for Mpox (emphasize recall)
```

**Performance Metrics**:
- Average Precision (AP) per class
- Mean Average Precision (mAP) across classes
- Precision, Recall, F1-Score per class
- Subset Accuracy (exact match)
- Hamming Loss (label-wise error)

### 3.3.5 Task 4: Severity Scoring Module

**Components**:
1. **Lesion Counter**: Counts detected lesions from YOLOv8 output
2. **Distribution Analyzer**: Maps lesions to anatomical regions
3. **Confluence Detector**: Analyzes segmentation mask overlaps
4. **MPOX-SSS Calculator**: Aggregates component scores

**MPOX-SSS Formula**:
```
Total Score = 
  Lesion Count Score (0-6) +
  Distribution Score (0-4) +
  Confluence Score (0-3) +
  Mucosal Score (0-2) +     # Requires clinical input
  Secondary Infection (0-2) +
  Complications (0-3)

Categories:
  Mild: 0-5
  Moderate: 6-12
  Severe: >12
```

**Validation**:
- Cohen's kappa with dermatologist consensus scores
- Mean Absolute Error (MAE) in total score
- Category agreement (3-class accuracy: mild/moderate/severe)

## 3.4 Fitzpatrick Skin Type Integration

### 3.4.1 Fitzpatrick Classification Model

**Training**:
- Separate CNN classifier (EfficientNet-B0)
- Public Fitzpatrick dataset + manual annotations
- 6-class output (Types I-VI)

**Integration**:
- Classify each input image
- Stratify performance metrics by skin type
- Apply skin type-specific thresholds if needed

### 3.4.2 Bias Mitigation Strategies

1. **Balanced Sampling**:
   - Equal representation in validation/test sets across types

2. **Targeted Augmentation**:
   - Heavier augmentation for underrepresented types (V-VI)
   - Color jitter emphasizing melanin variation

3. **Fairness Metrics**:
   - Equalized Odds: Equal TPR and FPR across types
   - Demographic Parity: Similar prediction rates across types

4. **Per-Type Thresholding**:
   - Optimize decision thresholds independently per Fitzpatrick type

## 3.5 Multimodal Integration Architecture

### 3.5.1 Data Modalities

**Visual Features** (Primary):
- Extracted from backbone CNN: 512-dim vector

**Symptom Features** (Binary/Categorical):
- Fever (Yes/No)
- Headache (Yes/No)
- Lymphadenopathy (Yes/No/Unknown)
- Malaise (Yes/No)
- Encoded as 4-dim binary vector

**Text Features** (Clinical Notes):
- Clinical history, progression notes
- Processed using BioClinicalBERT
- Embedding: 768-dim vector

**Metadata Features**:
- Lesion onset date (days since onset: continuous)
- Anatomical location (categorical: face/trunk/extremities/genitals)
- Exposure history (binary: known contact Yes/No)
- Travel history (binary: Yes/No)
- Encoded as 8-dim vector

### 3.5.2 Fusion Architecture

**Late Fusion with Attention**:
```
Visual Features (512-dim)
     ↓
[Dense(256) → ReLU → Dropout(0.3)]
     ↓
  Visual Embedding (256-dim)

Symptom Features (4-dim) + Metadata (8-dim)
     ↓
[Dense(64) → ReLU → Dropout(0.2)]
     ↓
  Clinical Embedding (64-dim)

Text Features (768-dim)
     ↓
[Dense(128) → ReLU → Dropout(0.3)]
     ↓
  Text Embedding (128-dim)

[Visual, Clinical, Text] Embeddings
     ↓
Cross-Modal Attention Layer
     ↓
Concatenate → Dense(256) → ReLU → Dropout(0.4)
     ↓
Output: Multi-label classification (6 classes)
```

**Training**:
- Pretrain individual modality encoders separately
- Fine-tune end-to-end with multimodal data
- Attention weights visualize modality importance

### 3.5.3 Ablation Studies

Evaluate contribution of each modality:
1. Image only (baseline)
2. Image + Symptoms
3. Image + Text
4. Image + Metadata
5. All modalities (full model)

Expected improvement: +5-10% accuracy from multimodal integration

## 3.6 Privacy-Preserving Implementation

### 3.6.1 On-Device Inference

**Model Optimization Pipeline**:
```
PyTorch Model (EfficientNet-B4 + heads)
     ↓
Export to ONNX format
     ↓
Convert to TensorFlow SavedModel
     ↓
Apply Post-Training Quantization (INT8)
     ↓
Convert to TensorFlow Lite (.tflite)
     ↓
Validate accuracy retention (<3% degradation)
```

**Quantization Strategy**:
- Dynamic range quantization for weights (FP32 → INT8)
- Integer quantization for activations where possible
- Hybrid quantization: Critical layers remain FP16
- Target model size: <20MB for segmentation, <10MB for classification

**Performance Targets**:
- Inference latency: <3 seconds per image
- Memory footprint: <150MB RAM
- Battery consumption: <5% per 100 inferences

### 3.6.2 Data Security Measures

**Encryption**:
- At rest: AES-256-GCM for stored images and data
- In transit: TLS 1.3 for any network communication
- Key management: Android KeyStore / iOS Keychain

**Anonymization**:
- Automatic removal of EXIF metadata
- Optional face blurring for non-lesion areas
- Unique patient ID (UUID) instead of personal identifiers

**Compliance**:
- HIPAA (USA): No PHI transmission without consent
- GDPR (EU): Right to deletion, data minimization
- Philippine Data Privacy Act 2012 (RA 10173): Consent, security measures

### 3.6.3 Federated Learning (Future Phase)

**Architecture**:
- On-device model training on local patient data
- Encrypted gradient updates sent to central server
- Differential privacy: Add noise to gradients (ε=0.5, δ=10⁻⁵)
- Secure aggregation without exposing individual data

## 3.7 Evaluation Methodology

### 3.7.1 Quantitative Metrics

**Lesion Detection**:
- mAP@0.5, mAP@0.5:0.95
- Precision, Recall, F1 per lesion type
- Inference time (ms)

**Segmentation**:
- Dice Coefficient ≥0.85
- IoU ≥0.80
- Boundary F1 ≥0.75

**Multi-Label Classification**:
- Average Precision per class
- mAP across all classes ≥0.88
- Subset Accuracy ≥0.75

**Severity Scoring**:
- Cohen's kappa ≥0.75 vs. dermatologist consensus
- MAE <1.5 points
- Category accuracy ≥85%

**Fitzpatrick Analysis**:
- Per-type accuracy variance <5%
- Equalized Odds ratio >0.90

### 3.7.2 Clinical Validation Protocol

**Phase 1: Retrospective Validation** (Months 6-7)
- Test on Philippine clinical dataset (n=200-300)
- Compare to ≥2 dermatologist diagnoses
- Calculate inter-rater agreement
- Measure time-to-diagnosis vs. standard workflow

**Phase 2: Prospective Clinical Trial** (Months 8-10)
- Deploy in 2-3 partner healthcare facilities
- Real-time use by clinicians during consultations
- N=50-100 suspected mpox cases
- Primary endpoint: Diagnostic concordance with PCR + clinical diagnosis
- Secondary endpoints: Time savings, clinician satisfaction, patient outcomes

**Phase 3: Usability Assessment**
- System Usability Scale (SUS) score ≥70
- Task completion rate ≥90%
- Error rate <5%
- Clinician satisfaction survey (5-point Likert scale)

### 3.7.3 Statistical Analysis

**Performance Comparison**:
- McNemar's test for paired diagnostic accuracy
- Bootstrap confidence intervals (95% CI) for metrics
- ANOVA for multi-group comparisons (Fitzpatrick types)

**Inter-Rater Reliability**:
- Cohen's kappa for pairwise agreement
- Fleiss' kappa for multi-rater agreement
- Intraclass correlation coefficient (ICC) for continuous scores

**Significance Level**: p < 0.05 for all tests

## 3.8 Ethical Considerations

### 3.8.1 Institutional Review Board (IRB)

- IRB approval obtained before Philippine clinical data collection
- Informed consent from all participants
- Waiver for retrospective analysis of de-identified images
- Annual progress reports to IRB

### 3.8.2 Patient Rights

- Voluntary participation, right to withdraw
- Data anonymization and secure storage
- No patient identifiable information in publications
- Access to study results upon request

### 3.8.3 Clinical Use Disclaimer

- System labeled as "research prototype, not for clinical diagnosis"
- Clinicians retain final diagnostic authority
- Recommendations reviewed by healthcare provider before acting
- Clear communication of system limitations to users

---

**[Implementation Timeline and Results in next artifact...]**
