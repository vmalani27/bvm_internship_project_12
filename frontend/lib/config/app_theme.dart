import 'package:flutter/material.dart';

// Common color palette for the app
class AppTheme {
  static ThemeData get themeData => ThemeData(
        brightness: Brightness.dark,
        primaryColor: primary,
        scaffoldBackgroundColor: bgColor,
        cardColor: cardBg,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.dark(
          primary: primary,
          secondary: secondary,
          surface: bgColor,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),
          displayMedium: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),
          displaySmall: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),
          headlineMedium: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),
          headlineSmall: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),
        ),
      );
  // Modern dark theme palette
  static const Color bgColor = Color(0xFF181A20);         // Deep dark background
  static const Color cardBg = Color(0xFF23262F);          // Slightly lighter card background
  static const Color accent = Color(0xFF7C3AED);          // Vibrant purple accent
  static const Color primary = Color(0xFF2563EB);         // Bright blue for primary actions
  static const Color secondary = Color(0xFF10B981);       // Teal/green for secondary actions
  static const Color textDark = Color(0xFFF1F5F9);        // Near-white for headings
  static const Color textBody = Color(0xFFCBD5E1);        // Soft gray for body text
}
