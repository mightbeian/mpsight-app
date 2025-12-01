/// MPSight - Computer Vision-Based Mpox Lesion Detection System
/// Main Application Entry Point
///
/// Version 2.0.0 - Comprehensive Multi-Modal Analysis

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

import 'providers/detection_provider.dart';
import 'providers/comprehensive_detection_provider.dart';
import 'providers/severity_provider.dart';
import 'services/privacy_service.dart';
import 'screens/home_screen.dart';
import 'screens/consent_screen.dart';

// Global list of available cameras
List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize cameras
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('Error initializing cameras: $e');
  }
  
  runApp(const MPSightApp());
}

class MPSightApp extends StatelessWidget {
  const MPSightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Privacy service (HIPAA/GDPR compliant)
        ChangeNotifierProvider(
          create: (_) => PrivacyService(
            config: PrivacyConfig.hipaaCompliant,
          ),
        ),
        // Legacy detection provider (single model)
        ChangeNotifierProvider(
          create: (_) {
            final provider = DetectionProvider();
            // Load model immediately
            provider.loadModel();
            return provider;
          },
        ),
        // Comprehensive detection provider (multi-model)
        ChangeNotifierProxyProvider<PrivacyService, ComprehensiveDetectionProvider>(
          create: (context) => ComprehensiveDetectionProvider(
            privacyService: context.read<PrivacyService>(),
          ),
          update: (context, privacyService, previous) =>
              previous ?? ComprehensiveDetectionProvider(privacyService: privacyService),
        ),
        // Severity assessment provider
        ChangeNotifierProvider(
          create: (_) => SeverityProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'MPSight',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C63FF),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C63FF),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'Poppins',
        ),
        themeMode: ThemeMode.system,
        home: const AppEntryPoint(),
      ),
    );
  }
}

/// App Entry Point - Handles consent flow
class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  bool _isLoading = true;
  bool _hasConsent = false;

  @override
  void initState() {
    super.initState();
    _checkConsent();
  }

  Future<void> _checkConsent() async {
    // Check if user has already provided consent
    final privacyService = context.read<PrivacyService>();
    
    // In production, check persisted consent status
    // For now, we'll show consent screen on first launch
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _hasConsent = privacyService.hasValidConsent;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading MPSight...'),
            ],
          ),
        ),
      );
    }

    if (!_hasConsent) {
      return ConsentScreen(
        onConsentGranted: () {
          setState(() {
            _hasConsent = true;
          });
        },
      );
    }

    return const HomeScreen();
  }
}
