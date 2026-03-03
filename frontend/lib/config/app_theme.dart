import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Premium, striking dark theme for a modern industrial workspace
class AppTheme {
  static ThemeData get themeData {
    final baseTextTheme = ThemeData.dark().textTheme;
    final customTextTheme = baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: bgColor,
      cardColor: cardBg,
      textTheme: GoogleFonts.interTextTheme(
        customTextTheme,
      ).apply(bodyColor: textBody, displayColor: textDark),
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: cardBg,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 12,
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  // Deep, rich background colors for depth
  static const Color bgColor = Color(0xFF0F111A); // Deepest navy/black
  static const Color cardBg = Color(0xFF191D2B); // Elevated dark card

  // Striking, vibrant accents
  static const Color primary = Color(
    0xFF3B82F6,
  ); // Vibrant blue for primary actions
  static const Color accent = Color(0xFF8B5CF6); // Electric violet accent
  static const Color secondary = Color(
    0xFF10B981,
  ); // Emerald green for secondary actions

  // High contrast text
  static const Color textDark = Color(0xFFF8FAFC); // Crisp white for headings
  static const Color textBody = Color(
    0xFF94A3B8,
  ); // Muted gray-blue for body text

  // Semantic colors
  static const Color success = Color(0xFF10B981); // Emerald success
  static const Color warning = Color(0xFFF59E0B); // Amber warning
  static const Color error = Color(0xFFEF4444); // Rose error
  static const Color info = Color(0xFF3B82F6); // Blue info
}
