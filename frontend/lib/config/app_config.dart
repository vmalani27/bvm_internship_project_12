import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dotenv/dotenv.dart';

class AppConfig {
  // URLs for different platforms
  static const String backendBaseUrlWindows = 'http://127.0.0.1:8000';
  static const String backendBaseUrlAndroid = 'http://172.29.250.34:5000';

  // Updated production URL
  static const String backendBaseUrlProd = 'http://pcbis.flashstudios.tech';

  // Choose which environment to use
  static const bool isProduction = false; // Set to true to use the new URL

  // Get backend URL based on platform and environment
  static String get backendBaseUrl {
    if (isProduction) return backendBaseUrlProd;

    if (kIsWeb) {
      return backendBaseUrlWindows; // Or desired default web URL
    } else if (Platform.isAndroid) {
      return backendBaseUrlAndroid;
    } else if (Platform.isWindows) {
      return backendBaseUrlWindows;
    } else {
      // Default fallback for other platforms (e.g., iOS, macOS, Linux)
      return backendBaseUrlAndroid;
    }
  }
}
