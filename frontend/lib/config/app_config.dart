// import 'dart:io';

class AppConfig {
  // URLs for different platforms
  static const String backendBaseUrlWindows = 'http://127.0.0.1:5000';
  // static const String backendBaseUrlAndroid = 'http://172.29.250.34:5000';
  
  // Updated production URL
  static const String backendBaseUrlProd = 'http://pcbis.flashstudios.tech';

  // Choose which environment to use
  static const bool isProduction = false; // Set to true to use the new URL

  // Get backend URL based on platform and environment
  static String get backendBaseUrl {
    if (isProduction) return backendBaseUrlProd;

    // For web-only build, always return default base URL
    return backendBaseUrlWindows; // This line can be changed to return _defaultBaseUrl if needed
  }
}