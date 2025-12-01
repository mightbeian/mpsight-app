/// Consent Screen
/// HIPAA/GDPR compliant consent collection for medical data processing

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/privacy_service.dart';

class ConsentScreen extends StatefulWidget {
  final VoidCallback onConsentGranted;

  const ConsentScreen({
    super.key,
    required this.onConsentGranted,
  });

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _agreedToTerms = false;
  bool _agreedToPrivacy = false;
  bool _agreedToDiagnostic = false;
  bool _agreedToStorage = false;
  bool _agreedToResearch = false;
  bool _isSubmitting = false;

  bool get _canProceed =>
      _agreedToTerms && _agreedToPrivacy && _agreedToDiagnostic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shield_outlined,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Privacy & Consent',
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Your privacy matters to us',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildInfoCard(
                      context,
                      'How We Protect Your Data',
                      [
                        _InfoItem(
                          icon: Icons.phone_android,
                          title: 'On-Device Processing',
                          description:
                              'All AI analysis happens locally on your device. Your images never leave your phone.',
                        ),
                        _InfoItem(
                          icon: Icons.lock,
                          title: 'Encrypted Storage',
                          description:
                              'Any saved data is encrypted using industry-standard AES-256 encryption.',
                        ),
                        _InfoItem(
                          icon: Icons.person_off,
                          title: 'De-identification',
                          description:
                              'Personal identifiers are removed or anonymized to protect your identity.',
                        ),
                        _InfoItem(
                          icon: Icons.gavel,
                          title: 'HIPAA/GDPR Compliant',
                          description:
                              'Our practices comply with international healthcare privacy regulations.',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Required Consent',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _buildConsentItem(
                      'Terms of Service',
                      'I have read and agree to the Terms of Service.',
                      _agreedToTerms,
                      (value) => setState(() => _agreedToTerms = value ?? false),
                      isRequired: true,
                    ),
                    _buildConsentItem(
                      'Privacy Policy',
                      'I have read and understand the Privacy Policy.',
                      _agreedToPrivacy,
                      (value) => setState(() => _agreedToPrivacy = value ?? false),
                      isRequired: true,
                    ),
                    _buildConsentItem(
                      'Diagnostic Analysis',
                      'I consent to the use of AI for analyzing skin images for diagnostic assistance.',
                      _agreedToDiagnostic,
                      (value) =>
                          setState(() => _agreedToDiagnostic = value ?? false),
                      isRequired: true,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Optional Consent',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _buildConsentItem(
                      'Local Data Storage',
                      'I consent to storing analysis results locally on my device for my records.',
                      _agreedToStorage,
                      (value) => setState(() => _agreedToStorage = value ?? false),
                      isRequired: false,
                    ),
                    _buildConsentItem(
                      'Research Contribution',
                      'I consent to contributing anonymized data to improve the AI model (optional).',
                      _agreedToResearch,
                      (value) =>
                          setState(() => _agreedToResearch = value ?? false),
                      isRequired: false,
                    ),
                    const SizedBox(height: 32),
                    _buildDisclaimerCard(context),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _canProceed ? _submitConsent : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () => _showPrivacyDetails(context),
                        child: const Text('Learn more about our privacy practices'),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    List<_InfoItem> items,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          item.icon,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentItem(
    String title,
    String description,
    bool value,
    ValueChanged<bool?> onChanged, {
    required bool isRequired,
  }) {
    return Card(
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            if (isRequired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Required',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          description,
          style: const TextStyle(fontSize: 12),
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildDisclaimerCard(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.medical_information,
              color: Colors.orange.shade700,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medical Disclaimer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'MPSight is a screening assistance tool only. It is NOT a diagnostic device '
                    'and should NOT replace professional medical evaluation. Always consult '
                    'a qualified healthcare provider for medical concerns.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitConsent() async {
    setState(() => _isSubmitting = true);

    try {
      final privacyService = context.read<PrivacyService>();

      // Build consent purposes
      List<ConsentPurpose> purposes = [ConsentPurpose.diagnosticAnalysis];
      if (_agreedToStorage) purposes.add(ConsentPurpose.dataStorage);
      if (_agreedToResearch) {
        purposes.add(ConsentPurpose.researchUse);
        purposes.add(ConsentPurpose.modelImprovement);
        purposes.add(ConsentPurpose.anonymizedAggregation);
      }

      // Record consent
      await privacyService.recordConsent(
        userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
        purposes: purposes,
      );

      widget.onConsentGranted();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving consent: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showPrivacyDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Privacy Details',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              const Text(
                'Data We Collect',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Images you choose to analyze (processed locally only)\n'
                '• Symptom information you provide\n'
                '• Analysis results (stored locally if you consent)\n'
                '• Anonymous usage statistics',
              ),
              const SizedBox(height: 16),
              const Text(
                'Data We DO NOT Collect',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Your name or personal identifiers\n'
                '• Your location (unless you provide it)\n'
                '• Your images are never uploaded to servers\n'
                '• No data is sold to third parties',
              ),
              const SizedBox(height: 16),
              const Text(
                'Your Rights',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Access your data at any time\n'
                '• Delete all stored data\n'
                '• Withdraw consent at any time\n'
                '• Request data export',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String title;
  final String description;

  _InfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
