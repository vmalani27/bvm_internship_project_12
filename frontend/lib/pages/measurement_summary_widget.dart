import 'package:bvm_manual_inspection_station/pages/submission_result_page.dart';
import 'package:flutter/material.dart';
import '../models/measurement_step_model.dart';
import '../config/app_theme.dart';
import '../services/api_service.dart';
import '../models/user_session.dart';

class MeasurementSummaryWidget extends StatelessWidget {
  final MeasurementStepModel model;

  const MeasurementSummaryWidget({Key? key, required this.model})
    : super(key: key);

  Future<void> _submitMeasurement(BuildContext context) async {
    final Map<String, String> measurements = Map<String, String>.from(
      model.measurements,
    );
    measurements['roll_number'] = UserSession.rollNumber ?? '';

    String? housingType;
    if (model.category != 'shaft') {
      housingType = model.category;
    }

    final success = await ApiService.submitMeasurement(
      category: model.category,
      productId: model.productId ?? '',
      measurements: measurements,
      housingType: housingType,
    );

    if (!context.mounted) return;

    // Navigate to the result page (replaces current route so back goes to dashboard)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => SubmissionResultPage(success: success)),
    );
  }

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
            const Icon(Icons.check_circle, color: AppTheme.success, size: 48),
            const SizedBox(height: 16),
            Text(
              'Review Your Measurements',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textBody,
              ),
            ),
            const SizedBox(height: 18),
            SingleChildScrollView(
              child: Column(
                children:
                    model.steps
                        .map(
                          (step) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    step['label'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppTheme.textDark,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    model.measurements[step['field']] ?? '-',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textBody,
                                    ),
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Submit Measurement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: () => _submitMeasurement(context),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.home),
              label: const Text('Back to Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                Navigator.of(
                  context,
                ).popUntil((route) => route.settings.name == '/dashboard');
              },
            ),
          ],
        ),
      ),
    );
  }
}
