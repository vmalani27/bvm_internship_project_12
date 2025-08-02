
class AppConfig {
  // Development environment (localhost)
  // static const String backendBaseUrlDev = 'http://localhost:8000';
  static const String backendBaseUrlDev = 'https://operating-technician-split-fd.trycloudflare.com';
    
  // Production environment (hosted backend)
  // Replace with your actual hosted backend URL
  static const String backendBaseUrlProd = 'https://your-backend-domain.com';
  
  // Choose which environment to use
  static const bool isProduction = false; // Set to true for production
  
  // Current backend URL based on environment
  static String get backendBaseUrl => isProduction ? backendBaseUrlProd : backendBaseUrlDev;
  
  // Alternative: Use environment variables or build-time configuration
  // static const String backendBaseUrl = String.fromEnvironment('BACKEND_URL', defaultValue: 'http://localhost:8000');
} 