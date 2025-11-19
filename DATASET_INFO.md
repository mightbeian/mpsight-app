# MSLD v2.0 Dataset Information

## Overview

MPSight uses the **Mpox Skin Lesion Dataset Version 2.0 (MSLD v2.0)**, a dermatologist-verified dataset specifically designed for multi-class classification of mpox and visually similar skin conditions.

## Dataset Details

### Source
- **Kaggle**: https://www.kaggle.com/datasets/joydippaul/mpox-skin-lesion-dataset-version-20-msld-v20
- **GitHub**: https://github.com/mHealthBuet/Mpox-Skin-Lesion-Dataset-v2
- **Released**: August 2024
- **Created by**: mHealth Buet research group, Bangladesh University of Engineering and Technology (BUET)

### Dataset Composition

| Class | Images | Percentage | Unique Patients | Description |
|-------|--------|------------|-----------------|-------------|
| Monkeypox | 284 | 37.6% | 202 | Primary target condition |
| HFMD | 161 | 21.3% | 143 | Hand-Foot-Mouth Disease |
| Healthy | 114 | 15.1% | 92 | Normal skin (control) |
| Chickenpox | 75 | 9.9% | 63 | Common differential diagnosis |
| Cowpox | 66 | 8.7% | 51 | Related orthopoxvirus |
| Measles | 55 | 7.3% | 44 | Vaccine-preventable exanthem |
| **Total** | **755** | **100%** | **541** | |

### Verification Process

1. **Reverse Image Search Validation**
   - Google Reverse Image Search used
   - Cross-referenced with reputable sources (journals, medical websites)
   - Ensured authenticity and credibility

2. **Professional Dermatologist Verification**
   - All images reviewed by qualified dermatologist
   - Clinical accuracy confirmed
   - Proper disease classification validated

### Dataset Structure

```
MSLD_v2.0/
├── Original Images/
│   ├── Fold1/
│   │   ├── Train/
│   │   ├── Validation/
│   │   └── Test/
│   ├── Fold2/
│   ├── Fold3/
│   ├── Fold4/
│   └── Fold5/
└── Augmented Images/
    ├── Fold1/
    │   └── Train/ (augmented only)
    ├── Fold2/
    ├── Fold3/
    ├── Fold4/
    └── Fold5/
```

### Augmentation Techniques

The augmented dataset includes:
- Rotation (various angles)
- Translation and reflection
- Shear transformations
- Hue, saturation, contrast adjustments
- Brightness variations
- Added noise for robustness
- Scaling variations

### Demographic Diversity

The dataset includes patients from multiple racial and ethnic backgrounds:
- Black/African American
- White/Caucasian
- Latino/Hispanic
- Asian

This diversity is crucial for developing models that work across the diverse Philippine population.

### 5-Fold Cross-Validation

MSLD v2.0 provides pre-defined 5-fold splits:
- Each fold contains train/validation/test splits
- Documented in `datalog.xlsx`
- Enables robust performance evaluation
- Reduces overfitting through multiple independent evaluations

### Image Naming Convention

```
[CLASS_CODE]_[PATIENT_ID]_[IMAGE_NUMBER]

Example: MKP_17_01
- MKP = Monkeypox
- 17 = Patient ID
- 01 = First image from this patient
```

### Class Codes

- **MKP**: Monkeypox
- **CHP**: Chickenpox
- **MSL**: Measles
- **CWP**: Cowpox
- **HFMD**: Hand-Foot-Mouth Disease
- **HEALTHY**: Healthy/Normal skin

## Why MSLD v2.0?

### Advantages

1. **Clinical Verification**: Double verification process ensures quality
2. **Multi-Class Structure**: Enables differential diagnosis training
3. **Diverse Population**: Represents multiple ethnicities
4. **Structured Organization**: 5-fold CV structure provided
5. **Augmented Data**: Extensive augmentation for robustness
6. **Recent Release**: Most up-to-date mpox dataset (August 2024)
7. **Adequate Size**: 755 images from 541 unique patients

### Challenges

1. **Class Imbalance**:
   - Monkeypox: 37.6% (largest)
   - Measles: 7.3% (smallest)
   - Requires class weighting and strategic augmentation

2. **Limited Samples for Some Classes**:
   - Measles: Only 55 images
   - Chickenpox: Only 75 images
   - May affect generalization for underrepresented conditions

3. **Web-Scraped Images**:
   - Varying quality and resolution
   - Different capture devices
   - Inconsistent lighting and backgrounds

## Training Recommendations

### Data Preprocessing

1. Resize all images to 640×640 (YOLOv8 standard)
2. Apply letterboxing to maintain aspect ratio
3. Normalize pixel values to [0, 1]
4. Use RGB color space consistently

### Addressing Class Imbalance

1. **Class Weighting**:
```python
class_weights = {
    'Monkeypox': 1.0,     # Baseline
    'HFMD': 1.76,
    'Healthy': 2.49,
    'Chickenpox': 3.79,
    'Cowpox': 4.30,
    'Measles': 5.16       # Highest weight
}
```

2. **Augmentation Strategy**:
   - Use provided augmented data for training
   - Apply additional augmentation to minority classes
   - Maintain original images for validation/testing

3. **Evaluation Metrics**:
   - Report per-class metrics (precision, recall, F1)
   - Use macro-averaged metrics (treats all classes equally)
   - Generate confusion matrices

### Training Configuration

```python
# Recommended YOLOv8 training parameters
epochs: 150
batch_size: 16
img_size: 640
patience: 20  # Early stopping
optimizer: AdamW
learning_rate: 0.001
lr_scheduler: cosine
class_weights: [see above]
```

## Expected Performance

Based on recent literature using MSLD v2.0:

- **Overall Accuracy**: 85-90%
- **Monkeypox Detection**:
  - Precision: 88-93%
  - Recall: 85-91%
  - F1-Score: 86-92%

- **Common Challenges**:
  - Confusion between Monkeypox and Cowpox (both orthopoxviruses)
  - Chickenpox misclassification when lesions are umbilicated
  - Measles detection difficulty due to limited training samples

## Citation

If you use MSLD v2.0 in your research, please cite:

```
Hasan, T., Faisal, S., & Nafisa, S. (2023). 
Mpox Skin Lesion Dataset Version 2.0 (MSLD v2.0). 
Kaggle. 
https://www.kaggle.com/datasets/joydippaul/mpox-skin-lesion-dataset-version-20-msld-v20
```

## Additional Resources

- **Original Paper**: Check Kaggle dataset page for associated publications
- **GitHub Repository**: https://github.com/mHealthBuet/Mpox-Skin-Lesion-Dataset-v2
- **Related Research**: Search for "MSLD v2.0" on Google Scholar

## Philippine Context

For Philippine-specific mpox information, refer to:

- **RITM (Research Institute for Tropical Medicine)**
- **DOH (Department of Health) Guidelines**
- **Philippine Case Report**: Ylaya et al. (2024) - First confirmed mpox case in Philippines
  - https://doi.org/10.3389/fmed.2024.1387407

---

**Dataset Version**: 2.0  
**Last Updated**: August 2024  
**Total Images**: 755  
**Total Patients**: 541  
**Classes**: 6