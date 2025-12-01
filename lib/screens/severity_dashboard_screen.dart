/// Severity Dashboard Screen
/// Displays MPOX-SSS scoring results with clinical recommendations

import 'package:flutter/material.dart';
import '../models/severity_score.dart';
import '../models/segmentation_result.dart';
import '../providers/comprehensive_detection_provider.dart';

class SeverityDashboardScreen extends StatelessWidget {
  final ComprehensiveAnalysisResult analysisResult;

  const SeverityDashboardScreen({
    super.key,
    required this.analysisResult,
  });

  @override
  Widget build(BuildContext context) {
    final severity = analysisResult.severityScore;
    final segmentation = analysisResult.segmentation;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Severity Assessment'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: severity == null
          ? const Center(
              child: Text('Severity analysis not available'),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSeverityHeader(context, severity),
                  const SizedBox(height: 24),
                  _buildScoreBreakdown(context, severity),
                  const SizedBox(height: 24),
                  if (segmentation != null)
                    _buildLesionSummary(context, segmentation),
                  const SizedBox(height: 24),
                  _buildRecommendations(context, severity),
                  const SizedBox(height: 24),
                  _buildDisclaimer(context),
                ],
              ),
            ),
    );
  }

  Widget _buildSeverityHeader(BuildContext context, MpoxSeverityResult severity) {
    final color = Color(severity.severityLevel.colorCode);

    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              severity.severityLevel.displayName.toUpperCase(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'MPOX-SSS Score: ${severity.totalScore}/100',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: severity.totalScore / 100,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Mild', style: TextStyle(color: Colors.white70)),
                Text('Moderate', style: TextStyle(color: Colors.white70)),
                Text('Severe', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBreakdown(
      BuildContext context, MpoxSeverityResult severity) {
    final components = severity.components;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildScoreRow(
              context,
              'Lesion Count',
              '${components.lesionCount} lesions',
              components.lesionCountScore,
              25,
              Icons.bubble_chart,
            ),
            _buildScoreRow(
              context,
              'Regional Distribution',
              '${components.regionsAffected} regions',
              components.distributionScore,
              25,
              Icons.map,
            ),
            _buildScoreRow(
              context,
              'Confluence',
              '${components.confluencePercentage.toStringAsFixed(1)}%',
              components.confluenceScore,
              25,
              Icons.blur_on,
            ),
            _buildScoreRow(
              context,
              'Mucosal Involvement',
              components.hasMucosalInvolvement ? 'Present' : 'Absent',
              components.mucosalScore,
              25,
              Icons.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(
    BuildContext context,
    String label,
    String detail,
    int score,
    int maxScore,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  detail,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$score/$maxScore',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLesionSummary(
      BuildContext context, SegmentationResult segmentation) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lesion Analysis',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoTile(
              'Total Lesions Detected',
              segmentation.lesionCount.toString(),
              Icons.fiber_manual_record,
            ),
            _buildInfoTile(
              'Total Affected Area',
              '${segmentation.totalAffectedAreaPercent.toStringAsFixed(2)}%',
              Icons.crop_square,
            ),
            _buildInfoTile(
              'Confluence Score',
              '${(segmentation.confluenceScore * 100).toStringAsFixed(1)}%',
              Icons.blur_on,
            ),
            _buildInfoTile(
              'Confluent Groups',
              segmentation.confluentGroups.toString(),
              Icons.group_work,
            ),
            _buildInfoTile(
              'Mucosal Involvement',
              segmentation.hasMucosalInvolvement ? 'Yes' : 'No',
              Icons.warning_amber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      dense: true,
    );
  }

  Widget _buildRecommendations(
      BuildContext context, MpoxSeverityResult severity) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medical_services, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Clinical Recommendations',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...severity.recommendations.map(
              (rec) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(rec)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer(BuildContext context) {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'This is an AI-assisted assessment tool for preliminary screening only. '
                'It is not a substitute for professional medical diagnosis. '
                'Please consult a healthcare provider for proper evaluation and treatment.',
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
