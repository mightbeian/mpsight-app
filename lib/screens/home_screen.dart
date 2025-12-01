/// Home Screen
/// Main dashboard with navigation to all MPSight features

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/detection_provider.dart';
import '../providers/comprehensive_detection_provider.dart';
import '../services/privacy_service.dart';
import 'camera_screen.dart';
import 'gallery_screen.dart';
import 'patient_assessment_screen.dart';
import 'severity_assessment_screen.dart';
import '../models/patient_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInitializing = true;
  PatientAssessment? _currentAssessment;

  @override
  void initState() {
    super.initState();
    _initializeModels();
  }

  Future<void> _initializeModels() async {
    // Load simple detection model for camera/gallery
    final detectionProvider = context.read<DetectionProvider>();
    await detectionProvider.loadModel();
    
    // Load comprehensive models (optional - can fail gracefully)
    final comprehensiveProvider = context.read<ComprehensiveDetectionProvider>();
    await comprehensiveProvider.loadAllModels();
    
    if (mounted) {
      setState(() => _isInitializing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.remove_red_eye,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'MPSight',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: _isInitializing
          ? _buildLoadingView()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(context),
                  const SizedBox(height: 24),
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _buildActionGrid(context),
                  const SizedBox(height: 24),
                  if (_currentAssessment != null) ...[
                    _buildCurrentAssessmentCard(context),
                    const SizedBox(height: 24),
                  ],
                  _buildInfoSection(context),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Loading AI Models...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a moment',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MPSight',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'AI-Powered Mpox Detection & Severity Assessment',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildFeatureChip('Multi-Class'),
                const SizedBox(width: 8),
                _buildFeatureChip('Segmentation'),
                const SizedBox(width: 8),
                _buildFeatureChip('Severity'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildModelStatusCard(BuildContext context) {
    return Consumer<ComprehensiveDetectionProvider>(
      builder: (context, provider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.memory),
                    const SizedBox(width: 8),
                    Text(
                      'AI Models Status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildModelStatus('Lesion Type Classifier', provider.isLesionTypeLoaded),
                _buildModelStatus('Disease Classifier', provider.isDiseaseClassifierLoaded),
                _buildModelStatus('Segmentation (U-Net)', provider.isSegmentationLoaded),
                _buildModelStatus('Severity Scoring', provider.isSeverityLoaded),
                _buildModelStatus('Fitzpatrick Classifier', provider.isFitzpatrickLoaded),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModelStatus(String name, bool isLoaded) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isLoaded ? Icons.check_circle : Icons.error_outline,
            size: 16,
            color: isLoaded ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 13),
          ),
          const Spacer(),
          Text(
            isLoaded ? 'Ready' : 'Not Loaded',
            style: TextStyle(
              fontSize: 12,
              color: isLoaded ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _buildActionCard(
          context,
          'Camera Scan',
          'Real-time detection',
          Icons.camera_alt,
          Colors.blue,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CameraScreen()),
          ),
        ),
        _buildActionCard(
          context,
          'Upload Image',
          'Analyze from gallery',
          Icons.photo_library,
          Colors.green,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GalleryScreen()),
          ),
        ),
        _buildActionCard(
          context,
          'Severity Score',
          'Calculate Mpox severity',
          Icons.medical_information,
          Colors.red,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SeverityAssessmentScreen()),
          ),
        ),
        _buildActionCard(
          context,
          'Patient Info',
          'Add symptoms & history',
          Icons.person_add,
          Colors.orange,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PatientAssessmentScreen(
                onAssessmentComplete: (assessment) {
                  setState(() => _currentAssessment = assessment);
                },
              ),
            ),
          ),
        ),
        _buildActionCard(
          context,
          'History',
          'View past analyses',
          Icons.history,
          Colors.purple,
          () => _showComingSoon(context, 'Analysis History'),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentAssessmentCard(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Current Patient Assessment',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => setState(() => _currentAssessment = null),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Risk Score: ${_currentAssessment!.overallRiskScore}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Symptoms reported: ${_currentAssessment!.symptoms.prodromalScore} indicators',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                Text(
                  'Important Notice',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'MPSight is a screening assistance tool designed to support healthcare '
              'professionals. It is NOT a diagnostic device and should not replace '
              'professional medical evaluation.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.amber.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Settings'),
              onTap: () => _showPrivacySettings(context),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About MPSight'),
              onTap: () => _showAbout(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Withdraw Consent'),
              onTap: () => _withdrawConsent(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    Navigator.pop(context);
    // TODO: Implement privacy settings screen
    _showComingSoon(context, 'Privacy Settings');
  }

  void _showAbout(BuildContext context) {
    Navigator.pop(context);
    showAboutDialog(
      context: context,
      applicationName: 'MPSight',
      applicationVersion: '2.0.0',
      applicationLegalese: '© 2024 MPSight Research Team',
      children: [
        const SizedBox(height: 16),
        const Text(
          'Computer Vision-Based Mpox Lesion Detection and Severity Assessment System',
        ),
      ],
    );
  }

  void _withdrawConsent(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Consent'),
        content: const Text(
          'Are you sure you want to withdraw your consent? This will delete all '
          'local data and you will need to provide consent again to use the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final privacy = context.read<PrivacyService>();
              await privacy.withdrawConsent('current_user');
              if (context.mounted) {
                Navigator.pop(context);
                // Restart app or navigate to consent screen
              }
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
    );
  }
}
