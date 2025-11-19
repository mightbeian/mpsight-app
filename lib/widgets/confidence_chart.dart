import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/detection_provider.dart';

class ConfidenceChart extends StatelessWidget {
  final DetectionResult result;

  const ConfidenceChart({
    super.key,
    required this.result,
  });

  // Updated colors for 6 classes (MSLD v2.0)
  Color _getColorForCondition(String condition) {
    switch (condition) {
      case 'Monkeypox':
        return const Color(0xFFE74C3C);  // Red - Critical alert
      case 'Cowpox':
        return const Color(0xFFD35400);  // Dark Orange - Related orthopoxvirus
      case 'Chickenpox':
        return const Color(0xFFE67E22);  // Orange - Common differential
      case 'Measles':
        return const Color(0xFFF39C12);  // Amber - Vaccine-preventable
      case 'HFMD':
        return const Color(0xFF3498DB);  // Blue - Pediatric condition
      case 'Healthy':
        return const Color(0xFF27AE60);  // Green - No pathology
      default:
        return Colors.grey;
    }
  }

  // Updated icons for 6 classes
  IconData _getIconForCondition(String condition) {
    switch (condition) {
      case 'Monkeypox':
        return Icons.warning_amber_rounded;
      case 'Cowpox':
        return Icons.coronavirus_outlined;
      case 'Chickenpox':
        return Icons.bubble_chart_outlined;
      case 'Measles':
        return Icons.sanitizer_outlined;
      case 'HFMD':
        return Icons.child_care_outlined;
      case 'Healthy':
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort confidences by value
    final sortedEntries = result.confidences.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary Detection Card
        _buildPrimaryCard(context),
        
        const SizedBox(height: 24),
        
        // Comparative Chart Title
        Text(
          'Comparative Analysis (6 Classes - MSLD v2.0)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3436),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Bar Chart
        SizedBox(
          height: 320,  // Increased height for 6 classes
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => Colors.black87,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${sortedEntries[group.x.toInt()].key}\n',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${rod.toY.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= sortedEntries.length) {
                        return const SizedBox();
                      }
                      final condition = sortedEntries[value.toInt()].key;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getIconForCondition(condition),
                              size: 18,
                              color: _getColorForCondition(condition),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              condition == 'HFMD' ? 'HFMD' : condition.split(' ')[0],
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                    reservedSize: 65,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}%',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 20,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey[300],
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barGroups: sortedEntries.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.value,
                      color: _getColorForCondition(entry.value.key),
                      width: 20,  // Slightly narrower for 6 classes
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: 100,
                        color: Colors.grey[200],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Detailed List
        _buildDetailedList(sortedEntries),
        
        const SizedBox(height: 24),
        
        // Disclaimer
        _buildDisclaimer(context),
      ],
    );
  }

  Widget _buildPrimaryCard(BuildContext context) {
    final isMonkeypox = result.primaryCondition == 'Monkeypox';
    final isHealthy = result.primaryCondition == 'Healthy';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isMonkeypox
              ? [Colors.red[400]!, Colors.red[600]!]
              : isHealthy
                  ? [Colors.green[400]!, Colors.green[600]!]
                  : [Colors.orange[400]!, Colors.orange[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isMonkeypox ? Colors.red : isHealthy ? Colors.green : Colors.orange).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getIconForCondition(result.primaryCondition),
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Primary Detection',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      result.primaryCondition,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Confidence: ${result.primaryConfidence.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedList(List<MapEntry<String, double>> entries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Breakdown',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 12),
        ...entries.map((entry) => _buildListItem(entry)),
      ],
    );
  }

  Widget _buildListItem(MapEntry<String, double> entry) {
    final color = _getColorForCondition(entry.key);
    final icon = _getIconForCondition(entry.key);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: entry.value / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${entry.value.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange[700],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This tool uses MSLD v2.0 for 6-class classification. Always consult a healthcare professional for proper diagnosis and treatment.',
              style: TextStyle(
                color: Colors.orange[900],
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
