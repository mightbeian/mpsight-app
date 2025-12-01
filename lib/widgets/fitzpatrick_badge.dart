/// Fitzpatrick Skin Type Badge Widget
/// Visual indicator for skin type classification

import 'package:flutter/material.dart';
import '../models/fitzpatrick_type.dart';

class FitzpatrickBadge extends StatelessWidget {
  final FitzpatrickType type;
  final double size;
  final bool showLabel;

  const FitzpatrickBadge({
    super.key,
    required this.type,
    this.size = 40,
    this.showLabel = true,
  });

  Color _getColorForType(FitzpatrickType type) {
    switch (type) {
      case FitzpatrickType.type1:
        return const Color(0xFFFFE4C4); // Bisque
      case FitzpatrickType.type2:
        return const Color(0xFFFFDAAB); // Peach
      case FitzpatrickType.type3:
        return const Color(0xFFD2A679); // Tan
      case FitzpatrickType.type4:
        return const Color(0xFFA67C52); // Light Brown
      case FitzpatrickType.type5:
        return const Color(0xFF8B5A2B); // Brown
      case FitzpatrickType.type6:
        return const Color(0xFF4A2C2A); // Dark Brown
      case FitzpatrickType.unknown:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForType(type);
    final textColor = type.index >= 4 ? Colors.white : Colors.black87;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.black26,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              type == FitzpatrickType.unknown
                  ? '?'
                  : '${type.index + 1}',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: size * 0.4,
              ),
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                type.displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                type.description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class FitzpatrickScaleSelector extends StatelessWidget {
  final FitzpatrickType? selectedType;
  final ValueChanged<FitzpatrickType>? onTypeSelected;

  const FitzpatrickScaleSelector({
    super.key,
    this.selectedType,
    this.onTypeSelected,
  });

  Color _getColorForType(FitzpatrickType type) {
    switch (type) {
      case FitzpatrickType.type1:
        return const Color(0xFFFFE4C4);
      case FitzpatrickType.type2:
        return const Color(0xFFFFDAAB);
      case FitzpatrickType.type3:
        return const Color(0xFFD2A679);
      case FitzpatrickType.type4:
        return const Color(0xFFA67C52);
      case FitzpatrickType.type5:
        return const Color(0xFF8B5A2B);
      case FitzpatrickType.type6:
        return const Color(0xFF4A2C2A);
      case FitzpatrickType.unknown:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final types = FitzpatrickType.values
        .where((t) => t != FitzpatrickType.unknown)
        .toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: types.map((type) {
        final isSelected = selectedType == type;
        final color = _getColorForType(type);
        final textColor = type.index >= 4 ? Colors.white : Colors.black87;

        return GestureDetector(
          onTap: () => onTypeSelected?.call(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 50 : 40,
            height: isSelected ? 50 : 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black26,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                '${type.index + 1}',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class FitzpatrickConfidenceCard extends StatelessWidget {
  final FitzpatrickClassificationResult result;

  const FitzpatrickConfidenceCard({
    super.key,
    required this.result,
  });

  Color _getColorForType(FitzpatrickType type) {
    switch (type) {
      case FitzpatrickType.type1:
        return const Color(0xFFFFE4C4);
      case FitzpatrickType.type2:
        return const Color(0xFFFFDAAB);
      case FitzpatrickType.type3:
        return const Color(0xFFD2A679);
      case FitzpatrickType.type4:
        return const Color(0xFFA67C52);
      case FitzpatrickType.type5:
        return const Color(0xFF8B5A2B);
      case FitzpatrickType.type6:
        return const Color(0xFF4A2C2A);
      case FitzpatrickType.unknown:
        return Colors.grey;
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
                const Icon(Icons.palette_outlined),
                const SizedBox(width: 8),
                Text(
                  'Fitzpatrick Skin Type',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            FitzpatrickBadge(
              type: result.predictedType,
              size: 50,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Confidence Distribution',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            ...FitzpatrickType.values
                .where((t) => t != FitzpatrickType.unknown)
                .map((type) {
              final confidence = result.typeConfidences[type] ?? 0.0;
              final color = _getColorForType(type);
              final isPredicted = type == result.predictedType;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black26),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 50,
                      child: Text(
                        type.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isPredicted ? FontWeight.bold : FontWeight.normal,
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
                            isPredicted ? color : color.withOpacity(0.5),
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
                              isPredicted ? FontWeight.bold : FontWeight.normal,
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
}
