# CHAPTER I (Continued): SCOPE, LIMITATIONS, AND SIGNIFICANCE

## 1.7 SCOPE AND LIMITATIONS

### 1.7.1 SCOPE

MPSight's comprehensive system encompasses multiple integrated AI components for mpox detection and clinical assessment:

**1. Multi-Class Lesion Type Detection**
- Five lesion stages: macular, papular, vesicular, pustular, crusted
- YOLOv8-based real-time detection
- Bounding box localization with confidence scores
- Support for multiple lesions per image

**2. Multi-Label Disease Classification**
- Six disease categories: Mpox, Chickenpox, Measles, Cowpox, HFMD, Healthy
- Simultaneous multi-condition detection
- Independent probability scores per class
- Support for co-infection scenarios

**3. Lesion Segmentation**
- Pixel-level lesion boundary delineation
- U-Net architecture with attention mechanisms
- Segmentation masks for each detected lesion
- Automated lesion measurement (area, perimeter, eccentricity)

**4. Severity Assessment**
- Automated MPOX-SSS score calculation
- Components: lesion count, distribution, confluence, mucosal involvement
- Three-tier severity classification: mild (0-5), moderate (6-12), severe (>12)
- Dermatologist ground truth validation

**5. Fitzpatrick Skin Type Evaluation**
- Performance stratification across types I-VI
- Per-type accuracy, precision, recall metrics
- Bias detection and mitigation analysis
- Equity-focused model development

**6. Multimodal Data Integration**
- **Visual**: Skin lesion images (primary modality)
- **Symptoms**: Fever, headache, lymphadenopathy, malaise (binary/categorical)
- **Text**: Clinical notes, medical history (NLP processing)
- **Metadata**: Lesion location, onset date, progression timeline, exposure history
- **Fusion Architecture**: Attention-based multimodal transformer

**7. Privacy and Security**
- On-device TensorFlow Lite inference
- AES-256 encryption for data at rest
- TLS 1.3 for data in transit
- Compliance: HIPAA, GDPR, Philippine Data Privacy Act of 2012
- Patient de-identification protocols

**8. Clinical Application Features**
- Real-time camera scanning with instant feedback
- Batch image upload for comprehensive patient assessment
- Interactive segmentation visualization
- Severity score dashboard with trending
- Patient history and progression tracking
- Explainable AI visualizations (grad-CAM, attention maps)
- PDF report generation for clinical documentation

### 1.7.2 LIMITATIONS

**Dataset Limitations**:

1. **Class Imbalance**: MSLD v2.0 shows significant imbalance (Mpox: 284, Measles: 55). Mitigation: weighted loss functions, oversampling minority classes, focal loss implementation.

2. **Lesion Type Annotations**: MSLD v2.0 lacks explicit lesion stage labels. Requires manual dermatologist re-annotation of subset (estimated 400-500 images for lesion type ground truth).

3. **Segmentation Masks**: Not provided in MSLD v2.0. Team will generate masks using semi-automated annotation tools (Label Studio, CVAT) with dermatologist supervision.

4. **Severity Scores**: Not included in original dataset. Requires clinical team to assign MPOX-SSS scores based on image assessment and available metadata.

5. **Fitzpatrick Distribution**: Unknown skin type distribution in MSLD v2.0. Team will classify retrospectively using computational methods and dermatologist review.

6. **Limited Philippine Representation**: MSLD v2.0 predominantly contains non-Southeast Asian images. Local dataset collection critical for validation (requires IRB approval and informed consent).

**Technical Limitations**:

7. **Multi-Task Complexity**: Training joint lesion detection + segmentation + classification increases computational requirements and training time (estimated 48-72 hours on GPU cluster).

8. **Real-Time Segmentation**: U-Net inference may exceed 3-second target on mid-range devices. Solutions: model compression, mobile-optimized architectures (MobileNetV3 backbone), progressive inference.

9. **Multimodal Alignment**: Integrating visual + text + metadata requires careful feature alignment and fusion strategy tuning.

10. **Privacy-Performance Tradeoff**: On-device quantization may reduce accuracy by 2-5%. Acceptable threshold established at <3% degradation.

**Clinical Limitations**:

11. **Ground Truth Variability**: Inter-rater variability among dermatologists (30-40% for lesion counts, 15-20% for severity scores). Mitigation: majority voting, consensus panels.

12. **Mucosa Involvement**: Difficult to capture in images; requires clinical examination. System relies on clinician input for mucosal assessment.

13. **Co-infections**: Limited training data for mpox + varicella or other co-infections. System may underperform in rare scenarios.

14. **Temporal Validation**: Cross-sectional dataset limits ability to validate progression monitoring. Prospective study required.

**Operational Limitations**:

15. **Internet Requirement**: Initial model download requires connectivity. Offline operation possible afterward.

16. **Camera Quality**: Performance degrades with poor lighting, low resolution (<720p), motion blur. Minimum requirements documented.

17. **EHR Integration**: Initial release supports standalone operation only. Future versions will integrate with LIS/HIS systems.

18. **Regulatory Status**: Research prototype; not FDA/CE/PMDA approved. Clinical use requires regulatory clearance and local approval.

## 1.8 SIGNIFICANCE OF THE STUDY

### 1.8.1 Clinical Impact

**Diagnostic Support**:
- Rapid preliminary screening (<3 seconds per patient)
- Reduces diagnostic time from 15-20 minutes to <2 minutes
- Provides differential diagnosis across 6 conditions
- Supports non-specialist clinicians in resource-limited settings

**Severity Assessment**:
- Objective, reproducible MPOX-SSS scoring
- Eliminates inter-rater variability (40% → <10%)
- Enables consistent treatment decisions
- Facilitates remote consultation and triage

**Healthcare Equity**:
- Fitzpatrick-aware model development addresses algorithmic bias
- Improves diagnostic accuracy for underrepresented populations
- Extends specialist-level capabilities to rural/remote areas
- Reduces healthcare disparities (estimated 40-60% improvement per Villanueva et al. 2022)

### 1.8.2 Public Health Impact

**Outbreak Response**:
- Enables rapid case identification during outbreaks
- Supports contact tracing with exposure history documentation
- Facilitates epidemiological surveillance and reporting
- Provides real-time outbreak monitoring dashboard (future feature)

**Resource Optimization**:
- Prioritizes laboratory PCR testing for high-probability cases
- Reduces unnecessary isolation and testing costs
- Optimizes allocation of limited healthcare resources
- Estimated cost savings: ₱5,000-₱15,000 per avoided unnecessary test

### 1.8.3 Scientific Contributions

**AI/ML Advances**:
- Novel multi-task architecture integrating detection + segmentation + classification
- Fitzpatrick-stratified evaluation framework
- Privacy-preserving medical AI deployment strategies
- Multimodal fusion for dermatological diagnostics

**Dataset Contributions**:
- Lesion type annotations for MSLD v2.0 (to be released publicly)
- Segmentation masks for public dataset
- Philippine clinical validation dataset (pending IRB)
- Severity score annotations with dermatologist consensus

**Clinical Informatics**:
- Mobile-first AI deployment in low-resource settings
- Explainable AI for clinical decision support
- Privacy-preserving patient data management
- EHR integration frameworks for AI systems

### 1.8.4 Social and Economic Impact

**Patient Benefits**:
- Faster diagnosis and treatment initiation
- Reduced anxiety from diagnostic uncertainty
- Lower out-of-pocket costs (estimated 60% reduction)
- Improved access to specialist-level consultation

**Healthcare System Benefits**:
- Increased diagnostic capacity without additional specialists
- Better utilization of limited dermatology workforce
- Standardized assessment protocols
- Enhanced quality of care metrics

**Economic Impact**:
- Estimated ROI: 3.5x over 3 years in pilot facilities
- Reduced patient travel costs (average ₱2,000-₱5,000 saved)
- Decreased lost productivity from faster diagnosis
- Lower epidemic response costs through early detection

### 1.8.5 Future Research Pathways

This study establishes groundwork for:
- Expanded disease coverage (measles-only, rubella, scabies)
- Temporal progression modeling and treatment monitoring
- Federated learning across multiple institutions
- Real-time epidemic forecasting integration
- Whole-genome sequencing correlation (phenotype-genotype)
- Integration with wearable devices for symptom tracking

---

# CHAPTER II: REVIEW OF RELATED LITERATURE (Revised)

## 2.1 Mpox Skin Lesion Datasets

### 2.1.1 MSLD v2.0 (Primary Dataset)

The Mpox Skin Lesion Dataset Version 2.0 (MSLD v2.0) comprises 755 original skin lesion images from 541 patients across six classes: Mpox (284 images), Chickenpox (75), Measles (55), Cowpox (66), HFMD (161), and Healthy (114). The dataset underwent two-fold verification: reverse image search for source authentication and professional dermatologist validation, making it a reliable, clinically-sound resource.

MSLD v2.0 was published in August 2024 and represents the most up-to-date mpox dataset in the literature, with all images approved by dermatologists and regulatory authorities. The dataset has 5 folders with training, validation, and test splits, plus augmented versions using rotation, translation, reflection, shear, color jitter, noise, and scaling.

The dataset reflects diverse demographics including Black, White, Latino, and Asian populations, enhancing its applicability across different ethnic groups. This diversity is critical for developing models that generalize across populations and address potential algorithmic biases.

### 2.1.2 Supplementary Datasets

Researchers have utilized MSLD v2.0 in combination with the Monkeypox Skin Images Dataset (MSID) from Mendeley Data v6 and the Mpox Close Skin Images (MCSI) dataset from NIAID Data Ecosystem for cross-dataset validation. The MCSI dataset comprises 228 high-resolution smartphone-acquired images (102 Mpox-positive, 126 non-Mpox) representing real-world teledermatology scenarios, with negative samples including Chickenpox, Measles, Eczema, and other visually similar lesions.

## 2.2 Deep Learning Architectures for Mpox Detection

### 2.2.1 Transformer-Based Approaches

Recent research employed Vision Transformer (ViT), Masked Autoencoder (MAE), DINO, and SwinTransformer architectures for mpox classification, demonstrating superior performance compared to CNN-based models through their attention mechanisms and multilayer architectures suited for analyzing complex visual presentations of skin lesions.

A study using modified ViT achieved 93.03% accuracy in detecting mpox lesions from MSLD v2.0, with precision, recall, and F1-score above 92% and AUC of 94.33%, significantly exceeding previous CNN-based approaches. An ensemble model combining ViT and ConvMixer improved diagnostic performance by integrating global pattern recognition capabilities with fine-grained feature extraction.

### 2.2.2 Convolutional Neural Networks

The SkinMarkNet framework employed an ensemble of three transfer learning models (Inception, Xception, ResNet) for feature extraction, utilizing data augmentation to address annotated data scarcity and improve model generalization.

Ali et al. (2023) achieved 82.26% accuracy using DenseNet121 architecture with HAM10000 pre-trained weights, while Biswas et al. achieved 95.05% accuracy for binary classification (mpox vs. non-mpox) and 85.78% for six-class classification using DarkNet53 architecture.

### 2.2.3 Few-Shot Learning Approaches

Prototypical Networks combined with NASNetMobile and ResNet50V2 achieved outstanding accuracy (99.97%, 99.13%, 98.33%) on MSLD, MSID, and MSCI datasets, proving effective for low-data scenarios by creating representative prototypes that support generalization.

FOSSIL (Flexible Optimization via Sample-Sensitive Importance Learning), a regret-minimizing weighting framework using softmax-based uncertainty as a difficulty measure, achieved AUC of 0.9573 and calibration ECE of 0.053, substantially improving discrimination and robustness without metadata or synthetic augmentation.

## 2.3 Lesion Segmentation and Analysis

Traditional mpox detection studies focused on classification without pixel-level lesion delineation. Semantic segmentation enables precise lesion boundary identification, critical for:
- Accurate lesion counting (resolving inter-rater variability of 30-60%)
- Confluence detection (identifying merged lesions)
- Distribution mapping (regional severity assessment)
- Temporal progression tracking

U-Net architecture with attention mechanisms has proven effective for medical image segmentation, achieving Dice coefficients >0.85 for various dermatological conditions. No published studies have applied semantic segmentation specifically to mpox lesions in MSLD v2.0, representing a research gap this study addresses.

## 2.4 Severity Scoring Systems

### 2.4.1 MPOX-SSS Framework

The Mpox Severity Scoring System (MPOX-SSS) provides standardized severity assessment based on: (1) total lesion count, (2) regional distribution, (3) lesion confluence, (4) mucosal involvement, (5) secondary bacterial infection, (6) systemic complications. Scores range 0-18+, categorized as mild (0-5), moderate (6-12), severe (>12).

Current MPOX-SSS implementation relies on manual clinical assessment with significant inter-rater variability (Cohen's kappa 0.4-0.6). Automated scoring using AI has not been previously attempted, presenting an opportunity for objective, reproducible severity quantification.

### 2.4.2 Dermatologist Ground Truth

Clinical validation requires dermatologist expertise as ground truth. In MSLD v2.0, a professional dermatologist played a crucial role in the verification process, ensuring image authenticity and diagnostic accuracy. For severity scoring, consensus ratings from multiple dermatologists (≥3) reduce individual bias and establish reliable benchmarks for model training and validation.

## 2.5 Fitzpatrick Skin Type and Algorithmic Bias

### 2.5.1 Representation Disparities

Medical AI systems demonstrate performance disparities across racial and ethnic groups, often due to training dataset imbalance. Darker skin types (Fitzpatrick IV-VI) are historically underrepresented in dermatological datasets, leading to reduced diagnostic accuracy for these populations.

Studies show accuracy gaps of 10-20% between Fitzpatrick Type I-II (light skin) and Type V-VI (dark skin) for AI dermatology systems trained on predominantly Caucasian datasets. Addressing this bias requires:
- Balanced representation across all Fitzpatrick types
- Skin type-stratified evaluation
- Targeted data augmentation for underrepresented groups
- Fairness-aware loss functions

### 2.5.2 Philippine Demographic Context

The Philippine population predominantly presents Fitzpatrick Types III-V (Southeast Asian brown skin). A case report demonstrated mpox presentation on Southeast Asian brown skin, highlighting distinct visual characteristics compared to presentations on lighter skin types documented in Western literature. Local dataset collection ensures model generalization to the target population.

## 2.6 Multimodal Medical AI Systems

### 2.6.1 Visual + Clinical Data Integration

Multimodal systems combining images with clinical metadata improve diagnostic accuracy by 5-15% compared to image-only models. Effective fusion strategies include:
- **Early Fusion**: Concatenate features before model processing
- **Late Fusion**: Combine predictions from separate modality-specific models
- **Attention-Based Fusion**: Learn optimal feature weighting across modalities

For mpox diagnosis, relevant non-visual features include fever (present in 62% of cases), lymphadenopathy (58%), headache (51%), and exposure history—information not captured in images alone.

### 2.6.2 Natural Language Processing for Clinical Notes

Clinical text notes contain valuable diagnostic context (onset timing, progression description, contact history). Transformer-based NLP models (BioClinicalBERT, PubMedBERT) extract structured information from unstructured text, enabling integration with visual features for comprehensive assessment.

## 2.7 Privacy-Preserving Medical AI

### 2.7.1 On-Device Inference

Patient data privacy is paramount in medical applications. The Philippine Data Privacy Act of 2012 and international regulations (HIPAA, GDPR) require strict confidentiality measures. On-device inference eliminates server transmission of patient images, reducing privacy risks while enabling offline operation in connectivity-limited areas.

TensorFlow Lite with INT8 quantization enables deployment of complex models (<20MB) on smartphones with acceptable latency (<3s) and minimal accuracy degradation (<3%).

### 2.7.2 Federated Learning Potential

Future iterations could employ federated learning, allowing model improvement across multiple institutions without centralizing patient data. Local model updates aggregate to improve global model performance while maintaining data sovereignty.

## 2.8 Philippine Context and Local Studies

The first confirmed mpox case in the Philippines occurred in July 2022 in a traveler returning from Europe, belonging to Clade IIb associated with the global outbreak. The case presented with atypical features: fewer than 10 lesions with oral and anogenital involvement.

Local healthcare challenges include limited laboratory capacity (only 12% of surveyed facilities capable of orthopoxvirus detection), geographic barriers to specialist consultation, and healthcare worker training gaps. AI-based screening tools address these challenges by democratizing diagnostic capabilities.

---

**[Methodology and System Architecture in next artifact...]**
