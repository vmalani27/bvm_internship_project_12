import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_content.dart';

class BvmManualInspectionStationApp extends StatelessWidget {
  const BvmManualInspectionStationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BVM Manual Inspection Station',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          primary: Colors.indigo,
          secondary: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A237E),
          elevation: 1,
          titleTextStyle: TextStyle(
            color: Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.indigo,
          contentTextStyle: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      home: const OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E), // Dark indigo
      appBar: AppBar(
        title: const Text('BVM Manual Inspection Station'),
      ),
      body: const HomeContent(),
    );
  }
} 