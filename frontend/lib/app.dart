import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_content.dart';
import 'config/app_theme.dart';

class BvmManualInspectionStationApp extends StatelessWidget {
  const BvmManualInspectionStationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BVM Manual Inspection Station',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData, // Use your custom theme
      home: const OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC), // Simple, clean background
      
      body: const HomeContent(),
    );
  }
}