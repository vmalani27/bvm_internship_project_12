import 'dart:math';

import 'package:bvm_manual_inspection_station/app.dart';
import 'package:bvm_manual_inspection_station/pages/measurement_category_page.dart';
import 'package:bvm_manual_inspection_station/pages/measurement_step_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/measurement_step_model.dart';
import '../config/app_theme.dart';
import '../config/app_config.dart';
import '../models/user_session.dart'; // Add this import

class MeasurementSummaryWidget extends StatelessWidget {
  final MeasurementStepModel model;
  
  const MeasurementSummaryWidget({
    Key? key, 
    required this.model
  }) : super(key: key);

  Future<void> _submitMeasurement(BuildContext context) async {
    final String baseUrl = AppConfig.backendBaseUrl;
    String endpoint;
    if (model.category == 'shaft') {
      endpoint = '/shaft_measurement';
    } else if (model.category == 'housing') {
      endpoint = '/housing_measurement';
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unknown category!'))
      );
      return;
    }

    // Create a copy of the measurements and add product_id and roll_number
    final Map<String, dynamic> payload = Map<String, dynamic>.from(model.measurements);
    payload['product_id'] = model.productId;
    payload['roll_number'] = UserSession.rollNumber; // <-- Add roll_number from session

    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
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
        SnackBar(content: Text('Submission failed: ${response.body}'))
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
                builder: (context) => MeasurementStepPage(
                  category: 'housing',
                  model: MeasurementStepModel(category: 'housing'),
                ),
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