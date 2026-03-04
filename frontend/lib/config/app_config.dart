class AppConfig {
  /// Backend API base URL.
  /// This can be overridden during build:
  /// flutter build web --dart-define=BACKEND_URL=https://api.example.com
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://localhost:8000',
  );
}
