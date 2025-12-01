/// Comprehensive Analysis Screen
/// Displays all analysis results from the multi-model pipeline

import 'package:flutter/material.dart';
import '../providers/comprehensive_detection_provider.dart';
import '../widgets/severity_indicator.dart';
import '../widgets/disease_confidence_chart.dart';
import '../widgets/fitzpatrick_badge.dart';
import '../widgets/lesion_type_indicator.dart';
import 'severity_dashboard_screen.dart';
import 'segmentation_viewer_screen.dart';

class ComprehensiveAnalysisScreen extends StatelessWidget {
  final ComprehensiveAnalysisResult result;

  const ComprehensiveAnalysisScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareResults(context),
            tooltip: 'Share Results',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session info
            _buildSessionInfo(context),
            const SizedBox(height: 16),

            // Severity summary (if available)
            if (result.severityScore != null) ...[
              _buildSeveritySummary(context),
              const SizedBox(height: 16),
            ],

            // Disease classification
            if (result.diseaseClassification != null) ...[
              _buildDiseaseSection(context),
              const SizedBox(height: 16),
            ],

            // Lesion type
            if (result.lesionType != null) ...[
              LesionTypeIndicator(result: result.lesionType!),
              const SizedBox(height: 16),
            ],

            // Segmentation summary
            if (result.segmentation != null) ...[
              _buildSegmentationSummary(context),
              const SizedBox(height: 16),
            ],

            // Fitzpatrick type
            if (result.fitzpatrickType != null) ...[
              FitzpatrickConfidenceCard(result: result.fitzpatrickType!),
              const SizedBox(height: 16),
            ],

            // Disclaimer
            _buildDisclaimer(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfo(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Analyzed: ${_formatDateTime(result.timestamp)} • '
                'Processing: ${result.processingTime.inMilliseconds}ms',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeveritySummary(BuildContext context) {
    final severity = result.severityScore!;

    return Card(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SeverityDashboardScreen(analysisResult: result),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.assessment),
                  const SizedBox(width: 8),
                  Text(
                    'MPOX-SSS Severity Assessment',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SeverityIndicator(
                    level: severity.severityLevel,
                    score: severity.totalScore,
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          severity.severityLevel.clinicalGuidance,
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap for detailed breakdown',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiseaseSection(BuildContext context) {
    final disease = result.diseaseClassification!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medical_services),
                const SizedBox(width: 8),
                Text(
                  'Disease Classification',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            DiseaseConfidenceChart(result: disease),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Detected Conditions',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            DetectedConditionsList(
              conditions: disease.detectedConditions,
              primary: disease.primaryCondition,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentationSummary(BuildContext context) {
    final seg = result.segmentation!;

    return Card(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SegmentationViewerScreen(segmentation: seg),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.grid_on),
                  const SizedBox(width: 8),
                  Text(
                    'Lesion Segmentation',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context,
                    '${seg.lesionCount}',
                    'Lesions',
                    Icons.fiber_manual_record,
                  ),
                  _buildStatItem(
                    context,
                    '${seg.lesionsByRegion.length}',
                    'Regions',
                    Icons.map,
                  ),
                  _buildStatItem(
                    context,
                    '${(seg.confluenceScore * 100).toStringAsFixed(0)}%',
                    'Confluence',
                    Icons.blur_on,
                  ),
                  _buildStatItem(
                    context,
                    '${seg.totalAffectedAreaPercent.toStringAsFixed(1)}%',
                    'Area',
                    Icons.crop_square,
                  ),
                ],
              ),
              if (seg.hasMucosalInvolvement) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, color: Colors.red.shade700, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Mucosal Involvement Detected',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimer(BuildContext context) {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: Colors.amber.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Important Disclaimer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This AI-assisted analysis is for preliminary screening purposes only. '
                    'It is not a substitute for professional medical diagnosis. '
                    'Please consult a qualified healthcare provider for proper evaluation and treatment.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber.shade900,
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

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  void _shareResults(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }
}
