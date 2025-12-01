/// Lesion Type Indicator Widget
/// Visual representation of lesion development stage

import 'package:flutter/material.dart';
import '../models/lesion_type.dart';

class LesionTypeIndicator extends StatelessWidget {
  final LesionTypeResult result;
  final bool showProgression;

  const LesionTypeIndicator({
    super.key,
    required this.result,
    this.showProgression = true,
  });

  Color _getColorForStage(LesionStage stage) {
    switch (stage) {
      case LesionStage.macular:
        return const Color(0xFF90CAF9); // Light Blue
      case LesionStage.papular:
        return const Color(0xFF64B5F6); // Blue
      case LesionStage.vesicular:
        return const Color(0xFFFFB74D); // Orange
      case LesionStage.pustular:
        return const Color(0xFFFF8A65); // Deep Orange
      case LesionStage.crusted:
        return const Color(0xFFA1887F); // Brown
      case LesionStage.unknown:
        return Colors.grey;
    }
  }

  IconData _getIconForStage(LesionStage stage) {
    switch (stage) {
      case LesionStage.macular:
        return Icons.circle_outlined;
      case LesionStage.papular:
        return Icons.circle;
      case LesionStage.vesicular:
        return Icons.water_drop_outlined;
      case LesionStage.pustular:
        return Icons.water_drop;
      case LesionStage.crusted:
        return Icons.texture;
      case LesionStage.unknown:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timeline),
                const SizedBox(width: 8),
                Text(
                  'Lesion Stage',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Primary stage indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getColorForStage(result.primaryStage).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getColorForStage(result.primaryStage),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getIconForStage(result.primaryStage),
                    size: 40,
                    color: _getColorForStage(result.primaryStage),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.primaryStage.displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          result.primaryStage.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(result.stageConfidences[result.primaryStage]! * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getColorForStage(result.primaryStage),
                    ),
                  ),
                ],
              ),
            ),

            if (showProgression) ...[
              const SizedBox(height: 20),
              Text(
                'Disease Progression Timeline',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 12),
              _buildProgressionTimeline(context),
            ],

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'All Stage Confidences',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            ...result.sortedConfidences.map((entry) {
              final stage = entry.key;
              final confidence = entry.value;
              final isPrimary = stage == result.primaryStage;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      _getIconForStage(stage),
                      size: 16,
                      color: _getColorForStage(stage),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 70,
                      child: Text(
                        stage.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isPrimary ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: confidence,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getColorForStage(stage),
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 45,
                      child: Text(
                        '${(confidence * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isPrimary ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressionTimeline(BuildContext context) {
    final stages = [
      LesionStage.macular,
      LesionStage.papular,
      LesionStage.vesicular,
      LesionStage.pustular,
      LesionStage.crusted,
    ];

    final currentIndex = stages.indexOf(result.primaryStage);

    return Row(
      children: List.generate(stages.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Connector line
          final stageIndex = index ~/ 2;
          final isPast = stageIndex < currentIndex;
          return Expanded(
            child: Container(
              height: 3,
              color: isPast
                  ? _getColorForStage(stages[stageIndex])
                  : Colors.grey[300],
            ),
          );
        } else {
          // Stage dot
          final stageIndex = index ~/ 2;
          final stage = stages[stageIndex];
          final isCurrent = stage == result.primaryStage;
          final isPast = stageIndex < currentIndex;

          return Column(
            children: [
              Container(
                width: isCurrent ? 32 : 24,
                height: isCurrent ? 32 : 24,
                decoration: BoxDecoration(
                  color: isCurrent || isPast
                      ? _getColorForStage(stage)
                      : Colors.grey[300],
                  shape: BoxShape.circle,
                  border: isCurrent
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 3,
                        )
                      : null,
                ),
                child: Center(
                  child: Icon(
                    _getIconForStage(stage),
                    size: isCurrent ? 18 : 14,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stage.displayName.substring(0, 3),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              ),
            ],
          );
        }
      }),
    );
  }
}
