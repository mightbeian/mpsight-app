# Additional Models Guide - MPSight

## Overview

Your MPSight app requires **5 specialized models** for comprehensive skin lesion analysis. This guide covers where to find or how to create each model.

## 📊 Required Models Summary

| Model | Input Size | Output | Status | Availability |
|-------|-----------|--------|--------|--------------|
| **Primary Disease Classifier** | 640×640×3 | 6 classes | ✅ Have it | `best_fp32.tflite` |
| **Lesion Type Classifier** | 640×640×3 | 5 classes | ❌ Need | Train required |
| **Disease Multi-label** | 640×640×3 | 6 classes (sigmoid) | ❌ Need | Train required |
| **U-Net Segmentation** | 256×256×3 | 256×256 mask | ⚠️ Convert | Available (PyTorch) |
| **Fitzpatrick Classifier** | 640×640×3 | 6 types | ⚠️ Limited | Few implementations |
| **MPOX-SSS Severity** | Variable | 4 scores | ✅ Rule-based | No ML needed |

---

## 1. ✅ Primary Disease Classifier (DONE)

**Status**: You already have this!

- **File**: `best_fp32.tflite` (5.8 MB)
- **Location**: `assets/models/`
- **Classes**: Monkeypox, Chickenpox, Measles, Cowpox, HFMD, Healthy
- **Used by**: `lib/providers/detection_provider.dart`

**Action**: None needed - test with `flutter run`

---

## 2. ❌ Lesion Type Classifier

**Status**: Not found on GitHub in TFLite format

**What it does**: Classifies lesion stage (Macular, Papular, Vesicular, Pustular, Crusted)

### GitHub Search Results:
- ❌ No pre-trained TFLite models found
- ⚠️ Research papers exist but no public implementations

### Your Options:

#### Option A: Train from Scratch
```python
from ultralytics import YOLO

# Download base model
model = YOLO('yolov8n-cls.pt')

# Train on lesion stage dataset
# You'll need to create/find this dataset
model.train(
    data='path/to/lesion_stages',  # Folder structure:
    # train/Macular/, train/Papular/, etc.
    epochs=50,
    imgsz=640,
    batch=16
)

# Export
model.export(format='tflite', imgsz=640)
```

#### Option B: Use Disease Classifier as Fallback
You can temporarily use your existing disease classifier and map results to stages. Update `comprehensive_detection_provider.dart`:

```dart
// Temporary mapping
LesionStage _inferStageFromDisease(SkinCondition condition) {
  switch (condition) {
    case SkinCondition.mpox:
      return LesionStage.vesicular; // Early mpox
    case SkinCondition.chickenpox:
      return LesionStage.vesicular;
    case SkinCondition.measles:
      return LesionStage.macular;
    // etc.
  }
}
```

#### Option C: Disable Feature Temporarily
Comment out lesion type loading in `comprehensive_detection_provider.dart`:

```dart
Future<void> loadAllModels() async {
  await Future.wait([
    // _loadLesionTypeModel(),  // Disabled for now
    _loadDiseaseClassifierModel(),
    _loadSegmentationModel(),
    _loadSeverityModel(),
    _loadFitzpatrickModel(),
  ]);
}
```

---

## 3. ❌ Multi-Label Disease Classifier

**Status**: Not found on GitHub

**What it does**: Detects multiple co-occurring diseases (e.g., Mpox + Chickenpox)

**Difference from your current model**: 
- Current: Single disease (softmax)
- Multi-label: Multiple diseases (sigmoid activation)

### Your Options:

#### Option A: Retrain with Multi-label
```python
import torch
import torch.nn as nn
from torchvision import models

class MultiLabelClassifier(nn.Module):
    def __init__(self):
        super().__init__()
        self.backbone = models.efficientnet_b2(pretrained=True)
        self.backbone.classifier = nn.Sequential(
            nn.Dropout(0.3),
            nn.Linear(1408, 6),
            nn.Sigmoid()  # Key difference!
        )
    
    def forward(self, x):
        return self.backbone(x)

# Train with BCELoss instead of CrossEntropyLoss
criterion = nn.BCELoss()
```

#### Option B: Use Current Model
Your current model can work for single-disease cases. Update code to use threshold:

```dart
// In detection_provider.dart
final threshold = 0.5;
List<String> detectedConditions = [];

for (int i = 0; i < _labels.length; i++) {
  double confidence = output[0][i];
  if (confidence > threshold) {
    detectedConditions.add(_labels[i]);
  }
}

// If multiple above threshold -> possible co-infection
bool coInfection = detectedConditions.length > 1;
```

---

## 4. ⚠️ U-Net Segmentation Model

**Status**: Many PyTorch implementations found, need conversion

**What it does**: Creates pixel-wise mask of lesion boundaries

### GitHub Repositories Found:

1. **pooya-mohammadi/unet-skin-cancer** (34 stars)
   - U-Net with attention for ISIC dataset
   - TensorFlow/Keras implementation
   - ✅ Easiest to convert to TFLite

2. **duylebkHCM/SkinLesionSegmentation** (3 stars)
   - U-Net from scratch
   - TensorFlow implementation
   - Has FastAPI deployment example

3. **xmindflow/DermoSegDiff** (84 stars)
   - State-of-the-art diffusion model
   - ❌ Too complex for mobile

### Recommended: Convert TensorFlow Model

**Step 1: Clone repository**
```powershell
git clone https://github.com/pooya-mohammadi/unet-skin-cancer
cd unet-skin-cancer
pip install -r requirements.txt
```

**Step 2: Train or use pre-trained (if available)**
```python
# Check if they have pre-trained weights
# If not, train on ISIC dataset
python train.py --data isic2018
```

**Step 3: Convert to TFLite**
```python
import tensorflow as tf

# Load trained model
model = tf.keras.models.load_model('path/to/unet_model.h5')

# Convert
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

# Save
with open('unet_segmentation.tflite', 'wb') as f:
    f.write(tflite_model)
```

**Step 4: Verify input/output shapes**
```python
import tensorflow as tf

interpreter = tf.lite.Interpreter(model_path='unet_segmentation.tflite')
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

print(f"Input: {input_details[0]['shape']}")   # Should be [1, 256, 256, 3]
print(f"Output: {output_details[0]['shape']}")  # Should be [1, 256, 256, 1]
```

**Step 5: Update your app**
```dart
// In comprehensive_detection_provider.dart
// Adjust image size for segmentation
img.Image segInput = img.copyResize(image, width: 256, height: 256);
```

### Alternative: Train Your Own

**Using ISIC 2018 Dataset:**
```python
from segmentation_models import Unet
from segmentation_models.losses import bce_dice_loss
from tensorflow.keras.optimizers import Adam

# Create U-Net
model = Unet(
    backbone_name='efficientnetb0',
    input_shape=(256, 256, 3),
    classes=1,
    activation='sigmoid'
)

model.compile(
    optimizer=Adam(1e-4),
    loss=bce_dice_loss,
    metrics=['accuracy', 'iou_score']
)

# Train
model.fit(train_dataset, validation_data=val_dataset, epochs=50)

# Export
model.save('unet_model.h5')
```

---

## 5. ⚠️ Fitzpatrick Skin Type Classifier

**Status**: Very limited availability

**What it does**: Classifies skin into Fitzpatrick types I-VI for bias evaluation

### GitHub Search Results:

1. **manasasnmng/FitzPatrick-Skin-type-classifier** (JavaScript)
   - Web-based, not suitable for mobile
   
2. **VladisRave/Skin-tone-classifier** (Python)
   - Non-AI color analysis approach
   - ❌ Not ML-based

3. **heba-abdullah5/skin_diseases_classification** (MobileNetV3)
   - Uses Fitzpatrick dataset for disease classification
   - ⚠️ Might have Fitzpatrick classifier component

### Your Options:

#### Option A: Train Your Own

**Challenge**: Getting balanced Fitzpatrick dataset is difficult

**Possible Datasets:**
- **Fitzpatrick17k**: Research dataset (requires approval)
- **Diverse Dermatology Images (DDI)**: Limited availability
- **Create synthetic dataset**: Use diverse face/skin images

**Training code:**
```python
from ultralytics import YOLO

model = YOLO('yolov8n-cls.pt')

# Dataset structure:
# fitzpatrick/
#   train/Type_I/, train/Type_II/, etc.

model.train(
    data='path/to/fitzpatrick',
    epochs=50,
    imgsz=640,
    batch=16
)

model.export(format='tflite', imgsz=640)
```

#### Option B: Use Pre-processing Alternative

**Color-based classification** (simpler, no ML):
```dart
FitzpatrickType _classifyBySkinTone(img.Image image) {
  // Extract average RGB from lesion-free regions
  double avgR = 0, avgG = 0, avgB = 0;
  int count = 0;
  
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      var pixel = image.getPixel(x, y);
      avgR += pixel.r;
      avgG += pixel.g;
      avgB += pixel.b;
      count++;
    }
  }
  
  avgR /= count;
  avgG /= count;
  avgB /= count;
  
  // Use ITA (Individual Typology Angle)
  double L = 0.299 * avgR + 0.587 * avgG + 0.114 * avgB;
  double ita = atan2(L - avgB, avgR - avgG) * 180 / pi;
  
  if (ita > 55) return FitzpatrickType.type1;
  if (ita > 41) return FitzpatrickType.type2;
  if (ita > 28) return FitzpatrickType.type3;
  if (ita > 10) return FitzpatrickType.type4;
  if (ita > -30) return FitzpatrickType.type5;
  return FitzpatrickType.type6;
}
```

#### Option C: Disable Feature
```dart
// In comprehensive_detection_provider.dart
Future<FitzpatrickClassificationResult?> _classifyFitzpatrick(
    img.Image image) async {
  // Return null or default value
  return FitzpatrickClassificationResult(
    predictedType: FitzpatrickType.unknown,
    typeConfidences: {},
    confidence: 0.0,
    timestamp: DateTime.now(),
  );
}
```

---

## 6. ✅ MPOX-SSS Severity Model

**Status**: No ML needed - use rule-based scoring

**What it does**: Calculates severity score from segmentation results

### Implementation: Already in Code!

The severity calculation is **rule-based** (no ML model needed):

```dart
// From comprehensive_detection_provider.dart
int _scoreLesionCount(int count) {
  if (count <= 10) return 5;
  if (count <= 25) return 10;
  if (count <= 50) return 15;
  if (count <= 100) return 20;
  return 25;
}

// Total = lesion count + distribution + confluence + mucosal
// Maximum score: 100 points
```

**No model file needed** - just ensure segmentation model works!

---

## 🎯 Action Plan

### Phase 1: Get App Running (Immediate)
1. ✅ Use existing `best_fp32.tflite` for disease detection
2. ❌ Disable or mock other models temporarily
3. ✅ Test basic functionality with single model

```dart
// Temporary modification
Future<void> loadAllModels() async {
  await _loadDiseaseClassifierModel();  // Only load this one
  // Comment out others
  notifyListeners();
}
```

### Phase 2: Add Segmentation (Week 1-2)
1. Clone `pooya-mohammadi/unet-skin-cancer`
2. Train on ISIC 2018 dataset
3. Convert to TFLite
4. Integrate into app

### Phase 3: Add Lesion Type (Week 3-4)
1. Create or find lesion stage dataset
2. Train YOLOv8 classifier
3. Export to TFLite
4. Add to app

### Phase 4: Add Fitzpatrick (Week 5-6)
1. Either train ML model OR
2. Implement color-based ITA calculation
3. Integrate for bias monitoring

### Phase 5: Add Multi-label (Optional)
1. Retrain disease classifier with sigmoid
2. Update inference code for multi-label
3. Handle co-infection cases

---

## 📚 Useful Resources

### Datasets
- **ISIC 2018**: Skin lesion segmentation - https://challenge.isic-archive.com/
- **MSLD v2.0**: Monkeypox/similar diseases - https://www.kaggle.com/datasets/dipuiucse/monkeypoxskinimagedataset
- **Fitzpatrick17k**: Skin type dataset (request access) - https://github.com/mattgroh/fitzpatrick17k

### Code Repositories
- **U-Net Skin Cancer**: https://github.com/pooya-mohammadi/unet-skin-cancer
- **Skin Lesion Segmentation**: https://github.com/duylebkHCM/SkinLesionSegmentation
- **YOLOv8 Documentation**: https://docs.ultralytics.com/

### Conversion Tools
- **ONNX to TFLite**: https://github.com/onnx/onnx-tensorflow
- **PyTorch to TFLite**: https://github.com/sithu31296/PyTorch-ONNX-TFLite
- **Model Optimization**: https://www.tensorflow.org/lite/performance/post_training_quantization

---

## 🔧 Quick Start Commands

### Convert Keras/TensorFlow Model
```python
import tensorflow as tf

model = tf.keras.models.load_model('model.h5')
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

with open('model.tflite', 'wb') as f:
    f.write(tflite_model)
```

### Convert PyTorch Model
```python
import torch
import torch.onnx
import onnx
from onnx_tf.backend import prepare
import tensorflow as tf

# PyTorch -> ONNX
dummy_input = torch.randn(1, 3, 640, 640)
torch.onnx.export(model, dummy_input, "model.onnx")

# ONNX -> TensorFlow
onnx_model = onnx.load("model.onnx")
tf_rep = prepare(onnx_model)
tf_rep.export_graph("saved_model")

# TensorFlow -> TFLite
converter = tf.lite.TFLiteConverter.from_saved_model("saved_model")
tflite_model = converter.convert()

with open("model.tflite", "wb") as f:
    f.write(tflite_model)
```

### Verify TFLite Model
```python
import tensorflow as tf
import numpy as np

interpreter = tf.lite.Interpreter(model_path='model.tflite')
interpreter.allocate_tensors()

# Get input/output details
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

print("Input shape:", input_details[0]['shape'])
print("Output shape:", output_details[0]['shape'])

# Test inference
test_input = np.random.randn(*input_details[0]['shape']).astype(np.float32)
interpreter.set_tensor(input_details[0]['index'], test_input)
interpreter.invoke()
output = interpreter.get_tensor(output_details[0]['index'])
print("Output:", output.shape)
```

---

## 📝 Summary

| Model | Recommendation | Timeline |
|-------|---------------|----------|
| Disease Classifier | ✅ **Use existing** | Now |
| Lesion Type | ⚠️ **Train or disable** | 2-4 weeks |
| Multi-label Disease | ⚠️ **Retrain or adapt existing** | 2-3 weeks |
| U-Net Segmentation | ✅ **Convert from GitHub** | 1-2 weeks |
| Fitzpatrick | ⚠️ **Use ITA or train** | 1-2 weeks |
| MPOX-SSS Severity | ✅ **Already implemented** | Now |

**Fastest path to working app**: Use existing disease classifier + mock/disable other features temporarily.

---

**Last Updated**: December 1, 2025
**Next Steps**: Decide which models are essential vs optional for MVP
