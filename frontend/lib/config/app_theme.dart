import 'package:flutter/material.dart';

// Soft, eye-friendly color palette for the app
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
  
  // Soft, eye-friendly dark theme palette
  static const Color bgColor = Color(0xFF1A1D23);         // Warmer dark background
  static const Color cardBg = Color(0xFF252831);          // Softer card background
  static const Color accent = Color(0xFF8B6FC7);          // Muted lavender accent
  static const Color primary = Color(0xFF5B8FE3);         // Soft blue for primary actions
  static const Color secondary = Color(0xFF7FB069);       // Gentle sage green for secondary actions
  static const Color textDark = Color(0xFFE8E9ED);        // Soft white for headings
  static const Color textBody = Color(0xFFB8BCC8);        // Gentle gray for body text
  
  // Additional soft colors for buttons and UI elements
  static const Color success = Color(0xFF68B984);         // Soft success green
  static const Color warning = Color(0xFFE4B55A);         // Warm amber warning
  static const Color error = Color(0xFFE07A7A);           // Soft error red
  static const Color info = Color(0xFF6BA3E0);            // Gentle info blue
}
