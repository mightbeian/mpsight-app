import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/severity_provider.dart';
import '../screens/severity_assessment_screen.dart';

class SeverityQuickAccess extends StatelessWidget {
  final String detectedCondition;
  final int estimatedLesionCount;

  const SeverityQuickAccess({
    Key? key,
    required this.detectedCondition,
    this.estimatedLesionCount = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (detectedCondition != 'Monkeypox') {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.red.shade50,
      child: InkWell(
        onTap: () {
          // Quick assessment for detected monkeypox
          final provider = context.read<SeverityProvider>();
          provider.quickAssessFromDetection(detectedCondition, estimatedLesionCount);
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SeverityAssessmentScreen(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.medical_information,
                  color: Colors.red.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assess Severity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Get WHO severity score and care recommendations',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: Colors.red.shade700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
