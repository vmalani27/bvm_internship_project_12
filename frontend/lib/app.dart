import 'package:flutter/material.dart';
import 'home_content.dart';

class BvmManualInspectionStationApp extends StatelessWidget {
  const BvmManualInspectionStationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BVM Manual Inspection Station',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BvmManualInspectionStationPage(),
    );
  }
}

class BvmManualInspectionStationPage extends StatelessWidget {
  const BvmManualInspectionStationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E), // Dark indigo
      appBar: AppBar(
        title: const Text('BVM Manual Inspection Station'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A237E),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BVM Manual Inspection Station',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Frontend Only',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Sidebar content goes here',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
      body: const HomeContent(),
    );
  }
} 