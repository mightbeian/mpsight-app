import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/severity_provider.dart';
import '../models/severity_assessment.dart';

class SeverityAssessmentScreen extends StatelessWidget {
  const SeverityAssessmentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Severity Assessment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<SeverityProvider>().resetAssessment();
            },
            tooltip: 'Reset Assessment',
          ),
        ],
      ),
      body: Consumer<SeverityProvider>(
        builder: (context, provider, child) {
          if (provider.currentAssessment != null) {
            return _buildResults(context, provider.currentAssessment!);
          }
          return _buildAssessmentForm(context, provider);
        },
      ),
    );
  }

  Widget _buildAssessmentForm(BuildContext context, SeverityProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.medical_information, size: 32, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Mpox Severity Scoring',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete this assessment to determine disease severity and receive care recommendations.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Lesion Count
          _buildLesionSection(context, provider),
          const SizedBox(height: 24),

          // Mucosal Involvement
          _buildMucosalSection(context, provider),
          const SizedBox(height: 24),

          // Symptoms by Category
          ...provider.categories.map((category) {
            return _buildSymptomCategory(context, provider, category);
          }).toList(),

          const SizedBox(height: 24),

          // Calculate Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                provider.calculateSeverity();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Calculate Severity Score',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLesionSection(BuildContext context, SeverityProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Skin Lesions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Estimated Lesion Count',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pin),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final count = int.tryParse(value);
                if (count != null) {
                  provider.setEstimatedLesionCount(count);
                }
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Current: ${provider.lesionSeverity.name.toUpperCase()}',
              style: TextStyle(
                color: _getSeverityColor(provider.lesionSeverity),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMucosalSection(BuildContext context, SeverityProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mucosal Involvement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Select number of affected mucosal sites:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: MucosalInvolvement.values.map((involvement) {
                final isSelected = provider.mucosalInvolvement == involvement;
                return ChoiceChip(
                  label: Text(_getMucosalLabel(involvement)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      provider.setMucosalInvolvement(involvement);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomCategory(BuildContext context, SeverityProvider provider, String category) {
    final symptoms = provider.getSymptomsByCategory(category);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          category,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${symptoms.where((s) => s.isPresent).length}/${symptoms.length} symptoms',
        ),
        children: symptoms.map((symptom) {
          return CheckboxListTile(
            title: Text(symptom.name),
            subtitle: Text('Score: ${symptom.score} points'),
            value: symptom.isPresent,
            onChanged: (value) {
              provider.updateSymptom(symptom.name, value ?? false);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResults(BuildContext context, SeverityAssessment assessment) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Score Card
          Card(
            color: _getResultColor(assessment.severityLevel),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.assessment, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    'Total Score: ${assessment.totalScore}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    assessment.severityLevel.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    assessment.severityDescription,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Urgency Indicators
          if (assessment.requiresICU)
            _buildUrgencyCard(
              icon: Icons.emergency,
              title: 'ICU Care Required',
              message: 'Patient requires intensive care unit admission',
              color: Colors.red,
            ),
          if (assessment.requiresHospitalization && !assessment.requiresICU)
            _buildUrgencyCard(
              icon: Icons.local_hospital,
              title: 'Hospitalization Recommended',
              message: 'Patient should be admitted for medical care',
              color: Colors.orange,
            ),

          const SizedBox(height: 16),

          // Score Breakdown
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Score Breakdown',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildScoreRow('Lesions', assessment.lesionSeverityDescription),
                  _buildScoreRow('Mucosal', assessment.mucosalInvolvement.name),
                  const Divider(),
                  ...assessment.symptomScoresByCategory.entries.map((entry) {
                    return _buildScoreRow(entry.key, '${entry.value} points');
                  }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Recommendations
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.recommend, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Recommendations',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...assessment.recommendations.map((rec) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 16)),
                          Expanded(
                            child: Text(
                              rec,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: rec.contains('⚠️') || rec.contains('🚨')
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Disclaimer
          Card(
            color: Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'This assessment is for informational purposes only and does not replace professional medical advice. Always consult with healthcare providers for diagnosis and treatment.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyCard({
    required IconData icon,
    required String title,
    required String message,
    required Color color,
  }) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  Color _getSeverityColor(SkinLesionSeverity severity) {
    switch (severity) {
      case SkinLesionSeverity.none:
        return Colors.green;
      case SkinLesionSeverity.mild:
        return Colors.blue;
      case SkinLesionSeverity.moderate:
        return Colors.orange;
      case SkinLesionSeverity.severe:
        return Colors.deepOrange;
      case SkinLesionSeverity.verySevere:
        return Colors.red;
    }
  }

  Color _getResultColor(SeverityLevel level) {
    switch (level) {
      case SeverityLevel.mild:
        return Colors.green;
      case SeverityLevel.moderate:
        return Colors.orange;
      case SeverityLevel.severe:
        return Colors.deepOrange;
      case SeverityLevel.critical:
        return Colors.red;
    }
  }

  String _getMucosalLabel(MucosalInvolvement involvement) {
    switch (involvement) {
      case MucosalInvolvement.none:
        return 'None';
      case MucosalInvolvement.mild:
        return '1 site';
      case MucosalInvolvement.moderate:
        return '2 sites';
      case MucosalInvolvement.severe:
        return '≥3 sites';
    }
  }
}
