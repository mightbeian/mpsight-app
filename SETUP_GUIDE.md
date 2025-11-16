# MPSight Setup Guide

Complete step-by-step guide to set up and run the MPSight application.

## 📋 Prerequisites Checklist

- [ ] Flutter SDK 3.0+ installed
- [ ] Android Studio installed
- [ ] Android SDK (API 21 minimum)
- [ ] Physical Android device or emulator
- [ ] Git installed
- [ ] Trained YOLOv8 TFLite model ready

## 🔧 Step-by-Step Setup

### 1. Verify Flutter Installation

```bash
flutter doctor
```

Fix any issues shown. You should see:
- ✓ Flutter (Channel stable)
- ✓ Android toolchain
- ✓ Android Studio

### 2. Clone Repository

```bash
git clone https://github.com/mightbeian/mpsight-app.git
cd mpsight-app
```

### 3. Create Required Directories

```bash
mkdir -p assets/models
mkdir -p assets/fonts
mkdir -p assets/icons
```

### 4. Add TFLite Model

**Option A: Convert Your YOLOv8 Model**
```python
from ultralytics import YOLO

# Load trained model
model = YOLO('best.pt')

# Export to TFLite
model.export(format='tflite', int8=True)  # With quantization
```

**Option B: Use Provided Model**
- Place your `yolov8_skin_classifier.tflite` in `assets/models/`

### 5. Download Poppins Font

1. Go to [Google Fonts - Poppins](https://fonts.google.com/specimen/Poppins)
2. Click "Download family"
3. Extract the ZIP file
4. Copy these files to `assets/fonts/`:
   - Poppins-Regular.ttf
   - Poppins-Medium.ttf
   - Poppins-SemiBold.ttf
   - Poppins-Bold.ttf

### 6. Install Dependencies

```bash
flutter pub get
```

Wait for all packages to download.

### 7. Update Android Configuration

The repository already includes the necessary Android configuration, but verify:

**android/app/build.gradle:**
```gradle
minSdk 21
targetSdk 34
```

**android/app/src/main/AndroidManifest.xml:**
Should include camera and storage permissions (already configured).

### 8. Connect Device or Start Emulator

**Physical Device:**
1. Enable Developer Options
2. Enable USB Debugging
3. Connect via USB
4. Run: `flutter devices`

**Emulator:**
1. Open Android Studio
2. Tools → Device Manager
3. Create/Start an emulator
4. Run: `flutter devices`

### 9. Run the Application

```bash
flutter run
```

First run will take longer as it builds.

## 🐛 Troubleshooting

### Issue: "Model file not found"

**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

Verify file path: `assets/models/yolov8_skin_classifier.tflite`

### Issue: "Camera permission denied"

**Solution:**
1. Go to device Settings → Apps → MPSight
2. Enable Camera permission
3. Restart app

### Issue: Font not loading

**Solution:**
- Check `pubspec.yaml` fonts section
- Verify font files are in `assets/fonts/`
- Run `flutter clean && flutter pub get`

### Issue: Gradle build fails

**Solution:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue: Slow inference

**Solutions:**
- Use INT8 quantized model
- Test on newer device
- Reduce camera resolution in `camera_screen.dart`

## 📱 Testing on Physical Device

1. **Grant Permissions:**
   - Camera access
   - Storage access (for gallery)

2. **Test Features:**
   - [ ] Model loads successfully ("System Ready" shows)
   - [ ] Live camera scan works
   - [ ] Camera captures frames every 2 seconds
   - [ ] Results display correctly
   - [ ] Gallery upload works
   - [ ] Confidence chart shows all 5 classes
   - [ ] Details modal opens

3. **Performance Check:**
   - Model loading time: ___ seconds
   - Inference time per image: ___ seconds
   - Camera preview smooth? Yes/No
   - UI responsive? Yes/No

## 🚀 Building Release APK

### For Testing
```bash
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

### For Distribution (Split by ABI)
```bash
flutter build apk --release --split-per-abi
```

Generates:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM)
- `app-x86_64-release.apk` (x86)

### For Play Store
```bash
flutter build appbundle --release
```

Bundle location: `build/app/outputs/bundle/release/app-release.aab`

## 📊 Model Requirements Reference

### Input
- **Shape:** `[1, 640, 640, 3]`
- **Type:** Float32
- **Range:** `[0.0, 1.0]` (normalized)
- **Format:** RGB

### Output
- **Shape:** `[1, 5]`
- **Type:** Float32
- **Classes:**
  - Index 0: Monkeypox
  - Index 1: Chickenpox
  - Index 2: Measles
  - Index 3: Acne
  - Index 4: Normal Skin

## 🔄 Updating the Model

1. Replace `assets/models/yolov8_skin_classifier.tflite`
2. Run:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```
3. Test all features

## 📝 Development Tips

### Hot Reload
- Press `r` in terminal to hot reload
- Press `R` for hot restart
- Press `q` to quit

### Debugging
```bash
# Enable verbose logging
flutter run --verbose

# View logs
flutter logs
```

### Code Quality
```bash
# Analyze code
flutter analyze

# Format code
flutter format .
```

## 🎨 Customization Guide

### Change App Name
**android/app/src/main/AndroidManifest.xml:**
```xml
android:label="Your App Name"
```

### Change App Icon
1. Place icon in `android/app/src/main/res/mipmap-*/`
2. Or use: `flutter pub run flutter_launcher_icons`

### Change Colors
**lib/main.dart:**
```dart
seedColor: const Color(0xFF6C63FF),  // Change this
```

### Modify Detection Classes
**lib/providers/detection_provider.dart:**
```dart
final List<String> _labels = [
  'Class1',
  'Class2',
  // ...
];
```

## 📞 Getting Help

- **Documentation:** Check README.md
- **Issues:** [GitHub Issues](https://github.com/mightbeian/mpsight-app/issues)
- **Email:** cabrera.cpaul@gmail.com

## ✅ Pre-Deployment Checklist

- [ ] Model file present and working
- [ ] All fonts loaded correctly
- [ ] Camera permission working
- [ ] Gallery upload working
- [ ] Real-time detection working
- [ ] Confidence chart displaying
- [ ] App tested on physical device
- [ ] Performance acceptable (<3s inference)
- [ ] No crashes during 10-minute usage
- [ ] Release APK builds successfully

---

**Ready to go!** 🎉

If you encounter any issues not covered here, please open an issue on GitHub.