import 'package:bvm_manual_inspection_station/app.dart';
import 'package:bvm_manual_inspection_station/pages/measurement_step_page.dart';
import 'package:bvm_manual_inspection_station/pages/housing_types_page.dart';
import 'package:flutter/material.dart';
import '../models/measurement_step_model.dart';
import '../config/app_theme.dart';
import '../services/api_service.dart';
import '../models/user_session.dart';

class MeasurementSummaryWidget extends StatelessWidget {
  final MeasurementStepModel model;
  
  const MeasurementSummaryWidget({
    Key? key, 
    required this.model
  }) : super(key: key);

  Future<void> _submitMeasurement(BuildContext context) async {
    // Prepare the measurements map for submission
    final Map<String, String> measurements = Map<String, String>.from(model.measurements);
    
    // Add roll number from session
    measurements['roll_number'] = UserSession.rollNumber ?? '';
    
    // Determine housing type for housing categories
    String? housingType;
    if (model.category != 'shaft') {
      housingType = model.category; // This will be 'oval', 'sqaure', 'angular', etc.
    }

    final success = await ApiService.submitMeasurement(
      category: model.category,
      productId: model.productId ?? '',
      measurements: measurements,
      housingType: housingType,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Measurement submitted!'))
      );
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _NextActionDialog(),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submission failed. Please try again.'))
      );
    }
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
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Submit Measurement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => _submitMeasurement(context),
            ),
            const SizedBox(height: 12),
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

class _NextActionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('What would you like to measure next?'),
      content: const Text('Choose a product type or log out.'),
      actions: [
        ElevatedButton.icon(
          icon: const Icon(Icons.home_work),
          label: const Text('Measure Housing'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HousingTypesPage(),
              ),
            );
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.settings_input_component),
          label: const Text('Measure Shaft'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MeasurementStepPage(
                  category: 'shaft',
                  model: MeasurementStepModel(category: 'shaft'),
                ),
              ),
            );
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Log Out / Check Out'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const OnboardingScreen()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }
}