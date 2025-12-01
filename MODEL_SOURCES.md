# Model Sources and Training Guide

## ❌ GitHub Model Search Results

After searching GitHub repositories, **no pre-trained TFLite models** were found that match MPSight's requirements:
- **Required**: 6 classes (Monkeypox, Chickenpox, Measles, Cowpox, HFMD, Healthy)
- **Required**: MSLD v2.0 dataset
- **Required**: TFLite format for mobile

### What Was Found:
1. **guy-977/Skinalyze** - MSLD v2.0 trained, but `.h5` format (not TFLite)
2. **Multiple YOLOv8 skin disease repos** - Different classes/datasets
3. **Research projects** - PyTorch `.pt` files only

## ✅ Recommended Solutions

### Option 1: Train Your Own Model (Best for Production)

#### Step 1: Get MSLD v2.0 Dataset

**Dataset Sources:**
- **Kaggle**: https://www.kaggle.com/datasets/dipuiucse/monkeypoxskinimagedataset
- **Original Paper**: Search "MSLD v2.0 Monkeypox Skin Lesion Dataset"
- **Alternative**: Contact dataset authors if needed

**Dataset Structure:**
```
msld_v2.0/
├── train/
│   ├── Monkeypox/
│   ├── Chickenpox/
│   ├── Measles/
│   ├── Cowpox/
│   ├── HFMD/
│   └── Healthy/
├── val/
│   └── (same structure)
└── test/
    └── (same structure)
```

#### Step 2: Train YOLOv8 Classifier

**Training Script:**
```python
from ultralytics import YOLO

# Load pre-trained YOLOv8n-cls model
model = YOLO('yolov8n-cls.pt')

# Train on MSLD v2.0
results = model.train(
    data='path/to/msld_v2.0',
    epochs=100,
    imgsz=640,
    batch=16,
    patience=20,
    name='msld_v2_classifier'
)

# Evaluate
metrics = model.val()

# Export to TFLite
model.export(format='tflite', imgsz=640)
```

**Or use command line:**
```bash
yolo classify train data=path/to/msld_v2.0 model=yolov8n-cls.pt epochs=100 imgsz=640
```

#### Step 3: Convert to TFLite

**Use the existing script:**
```powershell
# Update model path in convert_to_tflite.py (line 28)
python convert_to_tflite.py
```

**Manual conversion:**
```python
from ultralytics import YOLO
model = YOLO('path/to/best.pt')
model.export(format='tflite', imgsz=640, int8=False)
```

---

### Option 2: Download Pre-trained Base Model & Fine-tune

#### Step 1: Download Base Model
```powershell
python download_base_model.py
```

This downloads YOLOv8n-cls (1000 ImageNet classes) which you can fine-tune.

#### Step 2: Fine-tune on Your Data
```python
from ultralytics import YOLO

# Load base model
model = YOLO('yolov8n-cls.pt')

# Fine-tune on MSLD v2.0
model.train(
    data='path/to/msld_v2.0',
    epochs=50,  # Fewer epochs for fine-tuning
    imgsz=640,
    batch=16,
    freeze=10   # Freeze first 10 layers
)
```

---

### Option 3: Convert Existing Keras Model (Skinalyze)

If you want to use the Skinalyze model:

**1. Clone the repository:**
```bash
git clone https://github.com/guy-977/Skinalyze
cd Skinalyze
```

**2. Convert .h5 to TFLite:**
```python
import tensorflow as tf

# Load Keras model
model = tf.keras.models.load_model('skinNet.h5')

# Convert to TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

# Save
with open('skinalyze.tflite', 'wb') as f:
    f.write(tflite_model)
```

**⚠️ Important:** You'll need to update MPSight's code to match the model's:
- Input shape
- Output shape  
- Class order
- Preprocessing steps

---

## 🎯 Quick Start Options

### If You Have a Trained .pt Model:
```powershell
# 1. Place model in Downloads folder
# 2. Update path in convert_to_tflite.py (line 28)
# 3. Convert
python convert_to_tflite.py

# 4. Verify
Get-Item assets\models\best_fp32.tflite

# 5. Test
flutter clean
flutter pub get
flutter run
```

### If Starting from Scratch:
1. ✅ Download MSLD v2.0 dataset (Kaggle)
2. ✅ Run `python download_base_model.py`
3. ✅ Train model with script above
4. ✅ Export to TFLite
5. ✅ Copy to `assets/models/`

---

## 📚 Useful Resources

### Datasets:
- **MSLD v2.0**: https://www.kaggle.com/datasets/dipuiucse/monkeypoxskinimagedataset
- **DermNet**: https://dermnetnz.org/image-library
- **HAM10000**: https://www.kaggle.com/datasets/kmader/skin-cancer-mnist-ham10000

### Training Guides:
- **YOLOv8 Classification**: https://docs.ultralytics.com/tasks/classify/
- **TFLite Export**: https://docs.ultralytics.com/modes/export/
- **Mobile Optimization**: https://www.tensorflow.org/lite/performance/best_practices

### Similar Projects:
- **guy-977/Skinalyze**: Keras model on MSLD v2.0
- **NIKK0001/Skin_Disease_Detection-YOLO-V8**: YOLOv8 skin disease
- **ErikGef/Detecting-Skin-Diseases-using-yolov8**: YOLOv8 detection

---

## 🔧 Troubleshooting

### "Cannot find MSLD v2.0 dataset"
- Try multiple sources (Kaggle, research papers, contact authors)
- Alternative: Use similar datasets and retrain

### "Model too large for mobile"
```python
# Use quantization
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_types = [tf.float16]
```

### "Different class order than expected"
Update `_labels` list in `lib/providers/detection_provider.dart` to match your model's training order.

---

## 📝 Current Status

**Your Current Model:**
- File: `best_fp32.tflite` (5.8 MB)
- Location: `assets/models/`
- Status: ⚠️ Need to verify if this model is properly trained

**Next Steps:**
1. Test current model: `flutter run`
2. If it doesn't work well, follow training guide above
3. Consider getting MSLD v2.0 dataset for proper training

---

**Last Updated**: December 1, 2025
**Recommended**: Train your own model for best results
