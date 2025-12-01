/// Disease Confidence Chart Widget
/// Horizontal bar chart showing multi-label classification results

import 'package:flutter/material.dart';
import '../models/disease_classification.dart';

class DiseaseConfidenceChart extends StatelessWidget {
  final MultiLabelClassificationResult result;
  final bool showThreshold;
  final double threshold;

  const DiseaseConfidenceChart({
    super.key,
    required this.result,
    this.showThreshold = true,
    this.threshold = 0.5,
  });

  Color _getColorForCondition(SkinCondition condition) {
    switch (condition) {
      case SkinCondition.mpox:
        return const Color(0xFFE91E63); // Pink
      case SkinCondition.chickenpox:
        return const Color(0xFF9C27B0); // Purple
      case SkinCondition.measles:
        return const Color(0xFFFF5722); // Deep Orange
      case SkinCondition.cowpox:
        return const Color(0xFF795548); // Brown
      case SkinCondition.hfmd:
        return const Color(0xFF2196F3); // Blue
      case SkinCondition.healthy:
        return const Color(0xFF4CAF50); // Green
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedEntries = result.sortedByConfidence;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Warning badges
        if (result.possibleCoInfection || result.highUncertainty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Wrap(
              spacing: 8,
              children: [
                if (result.possibleCoInfection)
                  _buildWarningChip(
                    'Possible Co-infection',
                    Colors.orange,
                    Icons.warning_amber,
                  ),
                if (result.highUncertainty)
                  _buildWarningChip(
                    'High Uncertainty',
                    Colors.red,
                    Icons.help_outline,
                  ),
              ],
            ),
          ),

        // Confidence bars
        ...sortedEntries.map((entry) {
          final condition = entry.key;
          final confidence = entry.value;
          final isDetected = result.hasCondition(condition);
          final isPrimary = condition == result.primaryCondition;
          final color = _getColorForCondition(condition);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: _ConfidenceBar(
              label: condition.shortName,
              confidence: confidence,
              color: color,
              isDetected: isDetected,
              isPrimary: isPrimary,
              threshold: threshold,
              showThreshold: showThreshold,
            ),
          );
        }).toList(),

        // Threshold indicator
        if (showThreshold)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 2,
                  color: Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  'Detection threshold (${(threshold * 100).toInt()}%)',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildWarningChip(String label, Color color, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(fontSize: 12, color: color),
      ),
      backgroundColor: color.withOpacity(0.1),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _ConfidenceBar extends StatelessWidget {
  final String label;
  final double confidence;
  final Color color;
  final bool isDetected;
  final bool isPrimary;
  final double threshold;
  final bool showThreshold;

  const _ConfidenceBar({
    required this.label,
    required this.confidence,
    required this.color,
    required this.isDetected,
    required this.isPrimary,
    required this.threshold,
    required this.showThreshold,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Row(
            children: [
              if (isPrimary)
                const Icon(Icons.star, size: 14, color: Colors.amber),
              if (isDetected && !isPrimary)
                const Icon(Icons.check_circle, size: 14, color: Colors.green),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              // Background
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Progress
              FractionallySizedBox(
                widthFactor: confidence,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: isDetected ? color : color.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Threshold line
              if (showThreshold)
                Positioned(
                  left: threshold * (MediaQuery.of(context).size.width - 160),
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: Colors.red.withOpacity(0.7),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            '${(confidence * 100).toStringAsFixed(1)}%',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isDetected ? FontWeight.bold : FontWeight.normal,
              color: isDetected ? color : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

class DetectedConditionsList extends StatelessWidget {
  final List<SkinCondition> conditions;
  final SkinCondition primary;

  const DetectedConditionsList({
    super.key,
    required this.conditions,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    if (conditions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 12),
              Text('No pathological conditions detected'),
            ],
          ),
        ),
      );
    }

    return Column(
      children: conditions.map((condition) {
        final isPrimary = condition == primary;
        return Card(
          color: isPrimary
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPrimary
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
              child: Text(
                condition.shortName.substring(0, 1),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              condition.displayName,
              style: TextStyle(
                fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text('ICD-10: ${condition.icd10Code}'),
            trailing: isPrimary
                ? const Chip(
                    label: Text('Primary'),
                    backgroundColor: Colors.amber,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
