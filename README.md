# MPSight - Computer Vision-Based Mpox Lesion Detection System

![MPSight Logo](https://img.shields.io/badge/MPSight-v1.0.0-6C63FF?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

A Flutter-based mobile application for real-time skin lesion detection and multi-class classification, with primary focus on Monkeypox detection.

## 🎯 Features

- **Real-Time Camera Scanning** 📸
  - Live camera feed with automatic detection every 2 seconds
  - Instant results overlay on camera preview
  - Smooth animations and transitions

- **Gallery Image Upload** 🖼️
  - Select and analyze images from device gallery
  - High-quality image processing
  - Quick re-analysis capability

- **Comparative Confidence Visualization** 📊
  - Interactive bar charts showing all 5 skin conditions
  - Color-coded results for easy interpretation
  - Detailed breakdown with confidence percentages

- **Multi-Class Classification** 🏥
  - Monkeypox
  - Chickenpox
  - Measles
  - Acne
  - Normal Skin

- **Aesthetic Minimalist Design** 🎨
  - Material Design 3 principles
  - Smooth animations and micro-interactions
  - Professional healthcare interface

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.0 or higher)
- Android Studio with Android SDK (API 21+)
- A physical Android device or emulator
- Your trained YOLOv8 TFLite model

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/mightbeian/mpsight-app.git
   cd mpsight-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Add your TFLite model**
   - Create `assets/models/` directory
   - Place your `yolov8_skin_classifier.tflite` model in this folder

4. **Download fonts**
   - Download Poppins font from [Google Fonts](https://fonts.google.com/specimen/Poppins)
   - Place font files in `assets/fonts/`:
     - Poppins-Regular.ttf
     - Poppins-Medium.ttf
     - Poppins-SemiBold.ttf
     - Poppins-Bold.ttf

5. **Run the app**
   ```bash
   flutter run
   ```

## 📂 Project Structure

```
mpsight-app/
├── lib/
│   ├── main.dart                      # App entry point
│   ├── providers/
│   │   └── detection_provider.dart    # State management & TFLite
│   ├── screens/
│   │   ├── home_screen.dart          # Main dashboard
│   │   ├── camera_screen.dart        # Real-time scanning
│   │   └── gallery_screen.dart       # Image upload
│   └── widgets/
│       ├── feature_card.dart         # Reusable card component
│       └── confidence_chart.dart     # Visualization charts
├── assets/
│   ├── models/                       # TFLite model here
│   ├── fonts/                        # Font files
│   └── icons/                        # Additional icons
├── android/
│   └── app/
│       ├── src/main/AndroidManifest.xml
│       └── build.gradle
└── pubspec.yaml                      # Dependencies
```

## 🔧 Configuration

### Model Requirements

Your YOLOv8 TFLite model should:
- Accept input shape: `[1, 640, 640, 3]`
- Output shape: `[1, 5]` (probabilities for 5 classes)
- Classes in order: Monkeypox, Chickenpox, Measles, Acne, Normal Skin

### Customization

**Change detection interval** (camera_screen.dart):
```dart
Timer.periodic(Duration(seconds: 2), ...)  // Change seconds value
```

**Modify color scheme** (main.dart):
```dart
seedColor: const Color(0xFF6C63FF),  // Change to your color
```

**Add more classes** (detection_provider.dart):
```dart
final List<String> _labels = [
  'Monkeypox',
  'Chickenpox',
  // Add your classes here
];
```

## 📱 Screenshots

_(Add your app screenshots here after deployment)_

## 🏗️ Building for Production

### Build APK
```bash
flutter build apk --release --split-per-abi
```

### Build App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

## 🧪 Testing

```bash
# Run tests
flutter test

# Check code quality
flutter analyze
```

## 📊 Performance

- **Model Loading**: ~2-3 seconds on mid-range devices
- **Inference Time**: <1 second per image
- **Camera Detection**: Every 2 seconds (configurable)
- **App Size**: ~25-30 MB (with quantized model)

## ⚠️ Important Notes

- This is a **research prototype** for preliminary screening
- Not a replacement for professional medical diagnosis
- Always consult healthcare professionals for proper diagnosis
- Requires camera and storage permissions

## 🔐 Privacy & Security

- All processing happens on-device
- No data is sent to external servers
- No user data collection
- Camera images are processed in memory only

## 🛠️ Troubleshooting

### Model not loading
- Verify `.tflite` file is in `assets/models/`
- Check `pubspec.yaml` includes the assets path
- Run `flutter clean` and `flutter pub get`

### Camera permission denied
- Grant camera permission in device settings
- Uninstall and reinstall the app

### Slow inference
- Use quantized model (INT8)
- Test on newer device
- Reduce camera resolution

## 📝 Research Paper

This application is part of the thesis:
**"MPSight: Computer Vision-Based Mpox Lesion Detection and Severity Assessment System"**

Researchers:
- Christian Paul Cabrera
- Vanjo Luis Geraldez
- Yuri Luis Gler

Adviser: Tita R. Herradura

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Contact

- **Email**: cabrera.cpaul@gmail.com
- **LinkedIn**: [Christian Paul Cabrera](https://www.linkedin.com/in/mightbeian/)
- **GitHub**: [@mightbeian](https://github.com/mightbeian)

## 🙏 Acknowledgments

- College of Information and Computer Studies
- Computer Science Department
- All thesis advisers and panelists
- Open-source community

---

**Made with ❤️ for better healthcare accessibility**