import 'package:bvm_manual_inspection_station/pages/past_measurements.dart';
import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import 'measurement_step_page.dart';
import '../models/measurement_step_model.dart';
import '../elements/common_appbar.dart';

// MeasurementCategoryPage: Ask user to select Shaft or Housing for manual measurement
class MeasurementCategoryPage extends StatelessWidget {
  const MeasurementCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(64),
        child: BvmAppBar(title: 'Select Component to Measure'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Which component are you measuring?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark, letterSpacing: 0.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.straighten, color: AppTheme.primary),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MeasurementStepPage(
                      category: 'housing',
                      model: MeasurementStepModel(category: 'housing'),
                    ),
                  ),
                );
              },
              label: const Text('Housing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.primary)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 48),
                backgroundColor: AppTheme.cardBg,
                foregroundColor: AppTheme.primary,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: const BorderSide(color: AppTheme.primary, width: 1.2),
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings, color: AppTheme.secondary),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MeasurementStepPage(
                      category: 'shaft',
                      model: MeasurementStepModel(category: 'shaft'),
                    ),
                  ),
                );
              },
              label: const Text('Shaft', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.secondary)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 48),
                backgroundColor: AppTheme.cardBg,
                foregroundColor: AppTheme.secondary,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: const BorderSide(color: AppTheme.secondary, width: 1.2),
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.history, color: AppTheme.textDark),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PastMeasurementsPage()),
                );
              },
              label: const Text('View Past Measurements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(240, 48),
                backgroundColor: AppTheme.cardBg,
                foregroundColor: AppTheme.textDark,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: const BorderSide(color: AppTheme.textDark, width: 1.2),
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 