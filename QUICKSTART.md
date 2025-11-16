# \ud83d\ude80 Quick Start - MPSight Application

Get up and running in 5 minutes!

## Prerequisites
- Flutter 3.0+ installed ([Download here](https://flutter.dev))
- Android Studio with Android SDK
- Your trained YOLOv8 TFLite model

## Installation Steps

### 1. Clone the Repository
```bash
git clone https://github.com/mightbeian/mpsight-app.git
cd mpsight-app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Add Your Model
Place your TFLite model here:
```
assets/models/yolov8_skin_classifier.tflite
```

### 4. Download Fonts
1. Visit: https://fonts.google.com/specimen/Poppins
2. Download the font family
3. Extract and copy these files to `assets/fonts/`:
   - Poppins-Regular.ttf
   - Poppins-Medium.ttf
   - Poppins-SemiBold.ttf
   - Poppins-Bold.ttf

### 5. Run the App
```bash
flutter run
```

## \ud83d\udcf1 Opening in Android Studio

### Method 1: Command Line
1. Open terminal in project directory
2. Run: `studio .` (or `open -a "Android Studio" .` on Mac)

### Method 2: Android Studio
1. Open Android Studio
2. File → Open
3. Select the `mpsight-app` folder
4. Wait for Gradle sync
5. Click Run (green play button)

## \ud83d\udc1b Common Issues

### "Model not found"
- Verify file is at: `assets/models/yolov8_skin_classifier.tflite`
- Run: `flutter clean && flutter pub get`

### "Font not loading"
- Check fonts are in `assets/fonts/`
- Verify filenames match exactly
- Run: `flutter clean && flutter pub get`

### "Camera permission denied"
- Go to device Settings → Apps → MPSight
- Enable Camera permission
- Restart app

### Build fails
```bash
flutter clean
flutter pub get
flutter run
```

## \ud83d\udcdd Model Requirements

Your TFLite model should:
- Input: `[1, 640, 640, 3]` (RGB image)
- Output: `[1, 5]` (class probabilities)
- Classes: Monkeypox, Chickenpox, Measles, Acne, Normal Skin

## \ud83d\ude80 Next Steps

Once running:
1. Test camera scanning
2. Try gallery upload
3. View confidence charts
4. Check performance metrics

For detailed setup, see [SETUP_GUIDE.md](SETUP_GUIDE.md)

## \ud83d\udcde Need Help?

- Email: cabrera.cpaul@gmail.com
- Issues: https://github.com/mightbeian/mpsight-app/issues

---

**Happy Coding!** \ud83c\udf89
