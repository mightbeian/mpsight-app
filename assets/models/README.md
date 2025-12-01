# Trained Model Integration

## Current Model: MSLD v2.0 Dataset

This app uses a YOLOv8 classification model trained on the **MSLD v2.0** dataset.

### Model File
- **Filename:** `mpox_classifier.tflite`
- **Location:** This directory (`assets/models/`)
- **Status:** ⚠️ Placeholder - Needs to be replaced with your actual trained model

### Model Specifications

**Input:**
- Shape: `[1, 640, 640, 3]`
- Format: Float32 (normalized 0-1)
- Color: RGB

**Output:**
- Shape: `[1, 6]`
- Format: Float32 (confidence scores for each class)

**Classes (6 total):**
1. Chickenpox
2. Cowpox
3. Healthy
4. HFMD (Hand, Foot, and Mouth Disease)
5. Measles
6. Monkeypox

## How to Integrate Your Trained Model

### Option 1: Using the Conversion Script (Recommended)

If you have the PyTorch model file (`.pt` or `.pth`):

1. Update the model path in `convert_to_tflite.py`:
   ```python
   model_path = r"path\to\your\best.pt"
   ```

2. Run the conversion script:
   ```bash
   python convert_to_tflite.py
   ```

The script will automatically:
- Convert the model to TFLite format
- Copy it to the correct location
- Generate a labels.txt file

### Option 2: Manual Copy

If you already have a `.tflite` file:

1. Rename your model file to `mpox_classifier.tflite`
2. Replace the placeholder file in this directory
3. Ensure the model matches the specifications above

### Verification

After placing your model, verify it:

1. Check file size (should be > 1MB, typically 5-20MB)
   ```bash
   ls -lh assets/models/mpox_classifier.tflite
   ```

2. Run the Flutter app and check the debug console for:
   ```
   ✅ Model loaded successfully and ready for detection
   ```

## Troubleshooting

**Model not loading?**
- Verify the file is not corrupted (check file size)
- Ensure input/output shapes match the specifications
- Check Flutter console for error messages

**Wrong predictions?**
- Verify class order matches MSLD v2.0 dataset
- Check if preprocessing is correct (640x640, RGB, normalized)
- Ensure model was trained with correct data augmentation

## Notes

- The model will automatically use Android Neural Networks API (NNAPI) for hardware acceleration on supported devices
- Inference uses 4 threads for optimal performance
- If the model fails to load, the app will run in mock mode for testing
