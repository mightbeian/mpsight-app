/// Severity Indicator Widget
/// Visual indicator for MPOX-SSS severity levels

import 'package:flutter/material.dart';
import '../models/severity_score.dart';

class SeverityIndicator extends StatelessWidget {
  final SeverityLevel level;
  final int score;
  final bool showLabel;
  final double size;

  const SeverityIndicator({
    super.key,
    required this.level,
    required this.score,
    this.showLabel = true,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Color(level.colorCode).withOpacity(0.3),
                Color(level.colorCode),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(level.colorCode).withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$score',
                  style: TextStyle(
                    fontSize: size * 0.35,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '/100',
                  style: TextStyle(
                    fontSize: size * 0.15,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Color(level.colorCode),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              level.displayName.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class SeverityProgressBar extends StatelessWidget {
  final int score;
  final double height;
  final bool showMarkers;

  const SeverityProgressBar({
    super.key,
    required this.score,
    this.height = 24,
    this.showMarkers = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF4CAF50), // Green - Mild
                Color(0xFFFFEB3B), // Yellow
                Color(0xFFFF9800), // Orange - Moderate
                Color(0xFFF44336), // Red - Severe
              ],
              stops: [0.0, 0.33, 0.66, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Progress indicator
              Positioned(
                left: (score / 100) * (MediaQuery.of(context).size.width - 64) - 12,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black26, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$score',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showMarkers) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('0', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('Mild', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('Moderate', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('Severe', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('100', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ],
    );
  }
}

class ComponentScoreCard extends StatelessWidget {
  final String title;
  final String value;
  final int score;
  final int maxScore;
  final IconData icon;
  final Color? color;

  const ComponentScoreCard({
    super.key,
    required this.title,
    required this.value,
    required this.score,
    required this.maxScore,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    final percentage = score / maxScore;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: effectiveColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: effectiveColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$score/$maxScore',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: effectiveColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
