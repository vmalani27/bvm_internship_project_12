import 'package:flutter/material.dart';
import '../models/measurement_step_model.dart';
import '../config/app_theme.dart';

class MeasurementSummaryWidget extends StatelessWidget {
  final MeasurementStepModel model;
  
  const MeasurementSummaryWidget({
    Key? key, 
    required this.model
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardBg,
      margin: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 16),
            Text(
              'Review Your Measurements', 
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: AppTheme.textBody,
              )
            ),
            const SizedBox(height: 18),
            ...model.steps.map((step) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    step['label'], 
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textDark,
                    )
                  ),
                  Text(
                    model.measurements[step['field']] ?? '-',
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textBody,
                    )
                  ),
                ],
              ),
            )),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              icon: const Icon(Icons.home),
              label: const Text('Back to Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}