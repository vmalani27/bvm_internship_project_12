import 'dart:io';
import 'package:dotenv/dotenv.dart';

class AppConfig {
  // URLs for different platforms
  static const String backendBaseUrlWindows = 'http://localhost:5000';
  static const String backendBaseUrlAndroid = 'http://172.29.250.34:5000';

  // Optional: Production URL if needed
  static const String backendBaseUrlProd = 'https://your-backend-domain.com';

  // Choose which environment to use
  static const bool isProduction = false; // Toggle for production

  // Get backend URL based on platform and environment
  static String get backendBaseUrl {
    if (isProduction) return backendBaseUrlProd;

    if (Platform.isAndroid) {
      return backendBaseUrlAndroid;
    } else if (Platform.isWindows) {
      return backendBaseUrlWindows;
    } else {
      // Default fallback for other platforms (e.g., iOS, macOS, Linux)
      return backendBaseUrlAndroid;
    }
  }
}