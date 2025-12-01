# MPSight Model Training Requirements

## Overview

This document provides specifications for training the AI models required by MPSight. All models should be exported to TensorFlow Lite format for on-device inference.

## 1. Lesion Type Classifier

### Architecture
- Base: YOLOv8n-cls or EfficientNet-B0
- Input: 640×640×3 RGB
- Output: 5 classes (softmax)

### Classes
| Index | Class | Description |
|-------|-------|-------------|
| 0 | Macular | Flat, discolored patches |
| 1 | Papular | Raised, solid bumps |
| 2 | Vesicular | Fluid-filled blisters |
| 3 | Pustular | Pus-filled lesions |
| 4 | Crusted | Dried, scabbed lesions |

### Training Data Requirements
- Minimum 500 images per class
- Balanced distribution across Fitzpatrick types
- Multiple body regions represented
- Various lighting conditions

### Export Command (YOLOv8)
```bash
yolo export model=lesion_type_best.pt format=tflite
```

## 2. Multi-Label Disease Classifier

### Architecture
- Base: EfficientNet-B2 or ResNet50
- Input: 640×640×3 RGB
- Output: 6 classes (sigmoid - multi-label)

### Classes
| Index | Class | ICD-10 |
|-------|-------|--------|
| 0 | Mpox | B04 |
| 1 | Chickenpox | B01 |
| 2 | Measles | B05 |
| 3 | Cowpox | B08.010 |
| 4 | HFMD | B08.4 |
| 5 | Healthy | Z00.00 |

### Training Considerations
- Use sigmoid activation (not softmax) for multi-label
- Binary cross-entropy loss per class
- Consider class weights for imbalanced data
- Include co-infection examples if available

### PyTorch Training Example
```python
import torch.nn as nn

class MultiLabelClassifier(nn.Module):
    def __init__(self, num_classes=6):
        super().__init__()
        self.backbone = efficientnet_b2(pretrained=True)
        self.backbone.classifier = nn.Sequential(
            nn.Dropout(0.3),
            nn.Linear(1408, num_classes),
            nn.Sigmoid()
        )
    
    def forward(self, x):
        return self.backbone(x)

# Loss function
criterion = nn.BCELoss()
```

## 3. U-Net Segmentation Model

### Architecture
- Base: U-Net with attention gates
- Input: 256×256×3 RGB
- Output: 256×256×1 binary mask

### Attention U-Net Structure
```
Encoder:
  Conv Block 1: 64 filters
  Conv Block 2: 128 filters
  Conv Block 3: 256 filters
  Conv Block 4: 512 filters

Bottleneck: 1024 filters

Decoder (with attention gates):
  Up Block 4: 512 filters + Attention
  Up Block 3: 256 filters + Attention
  Up Block 2: 128 filters + Attention
  Up Block 1: 64 filters + Attention

Output: 1x1 conv + Sigmoid
```

### Training Data Requirements
- Pixel-wise annotated lesion masks
- At least 1000 annotated images
- Include various lesion sizes
- Multiple lesions per image

### Loss Function
```python
def dice_bce_loss(pred, target):
    bce = F.binary_cross_entropy(pred, target)
    
    pred_flat = pred.view(-1)
    target_flat = target.view(-1)
    intersection = (pred_flat * target_flat).sum()
    dice = 1 - (2. * intersection + 1) / (pred_flat.sum() + target_flat.sum() + 1)
    
    return bce + dice
```

## 4. MPOX-SSS Severity Model

### Option A: Rule-Based (No ML)
The severity score can be calculated algorithmically from segmentation results:

```python
def calculate_severity(lesion_count, regions_affected, confluence, has_mucosal):
    # Lesion count score (0-25)
    if lesion_count <= 10: lc_score = 5
    elif lesion_count <= 25: lc_score = 10
    elif lesion_count <= 50: lc_score = 15
    elif lesion_count <= 100: lc_score = 20
    else: lc_score = 25
    
    # Distribution score (0-25)
    dist_score = min(25, regions_affected * 3)
    
    # Confluence score (0-25)
    conf_score = int(confluence * 25)
    
    # Mucosal score (0 or 25)
    mucosal_score = 25 if has_mucosal else 0
    
    return lc_score + dist_score + conf_score + mucosal_score
```

### Option B: ML-Based
- Input: Concatenated features from other models + patient data
- Output: 4 component scores or single severity score
- Training: Use dermatologist consensus ratings as ground truth

### Dermatologist Rating Collection
```json
{
  "image_id": "IMG_001",
  "ratings": [
    {
      "rater_id_hash": "abc123",
      "severity": "moderate",
      "score": 55,
      "components": {
        "lesion_count": 15,
        "distribution": 12,
        "confluence": 10,
        "mucosal": 18
      },
      "years_experience": 12,
      "board_certified": true
    }
  ]
}
```

## 5. Fitzpatrick Skin Type Classifier

### Architecture
- Base: EfficientNet-B0 or MobileNetV3
- Input: 640×640×3 RGB
- Output: 6 classes (softmax)

### Classes
| Index | Type | Description |
|-------|------|-------------|
| 0 | Type I | Very fair, always burns |
| 1 | Type II | Fair, usually burns |
| 2 | Type III | Medium, sometimes burns |
| 3 | Type IV | Olive, rarely burns |
| 4 | Type V | Brown, very rarely burns |
| 5 | Type VI | Dark brown/black, never burns |

### Training Data Requirements
- Balanced representation across all types
- Minimum 300 images per type
- Various body regions
- Consistent lighting where possible

### Bias Evaluation
After training, evaluate performance equity:

```python
def evaluate_fairness(model, test_loader_by_type):
    metrics = {}
    for skin_type, loader in test_loader_by_type.items():
        metrics[skin_type] = {
            'accuracy': calculate_accuracy(model, loader),
            'fpr': calculate_false_positive_rate(model, loader),
            'fnr': calculate_false_negative_rate(model, loader),
        }
    
    # Calculate disparity
    accuracies = [m['accuracy'] for m in metrics.values()]
    max_disparity = max(accuracies) - min(accuracies)
    
    return metrics, max_disparity
```

## TFLite Export

### PyTorch to TFLite
```python
import torch
import tensorflow as tf

# Export PyTorch to ONNX
torch.onnx.export(model, dummy_input, "model.onnx")

# Convert ONNX to TF SavedModel
import onnx
from onnx_tf.backend import prepare
onnx_model = onnx.load("model.onnx")
tf_rep = prepare(onnx_model)
tf_rep.export_graph("saved_model")

# Convert to TFLite
converter = tf.lite.TFLiteConverter.from_saved_model("saved_model")
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

with open("model.tflite", "wb") as f:
    f.write(tflite_model)
```

### Quantization (Recommended for Mobile)
```python
converter = tf.lite.TFLiteConverter.from_saved_model("saved_model")
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_types = [tf.float16]
tflite_model = converter.convert()
```

## Model Validation Checklist

- [ ] Input shape matches expected [1, H, W, 3]
- [ ] Output shape matches expected classes
- [ ] Inference time < 1 second on mid-range device
- [ ] Model size < 50MB (quantized)
- [ ] Tested on all Fitzpatrick types
- [ ] Validated against dermatologist consensus
- [ ] Cross-validated (k=5 minimum)
