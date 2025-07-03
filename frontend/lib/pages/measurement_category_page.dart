import 'package:flutter/material.dart';
import 'measurement_step_page.dart';

// MeasurementCategoryPage: Ask user to select Shaft or Housing for manual measurement
class MeasurementCategoryPage extends StatelessWidget {
  const MeasurementCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Component to Measure')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Which component are you measuring?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.straighten),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MeasurementStepPage(category: 'housing'),
                  ),
                );
              },
              label: const Text('Housing', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 48),
                backgroundColor: Color(0xFF1976D2),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MeasurementStepPage(category: 'shaft'),
                  ),
                );
              },
              label: const Text('Shaft', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 48),
                backgroundColor: Color(0xFF388E3C),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 