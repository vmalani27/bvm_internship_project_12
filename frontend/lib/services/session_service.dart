import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';
import '../models/login_response.dart';
import '../models/user_session_model.dart';

class SessionService {
  static const String SESSION_KEY = 'user_session_id';

  // Store session ID locally
  static Future<void> storeSessionId(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SESSION_KEY, sessionId);
  }

  // Get stored session ID
  static Future<String?> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SESSION_KEY);
  }

  // Clear session ID
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SESSION_KEY);
  }

  // Check if user has active session
  static Future<bool> hasActiveSession() async {
    final sessionId = await getSessionId();
    return sessionId != null;
  }

  // Create user session (login)
  static Future<LoginResponse?> createUserSession({
    required String rollNumber,
    required String name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.backendBaseUrl}/user_entry'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'roll_number': rollNumber,
          'name': name,
        }),
      );

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
        
        // Store session ID locally
        await storeSessionId(loginResponse.sessionId);
        
        return loginResponse;
      }
      return null;
    } catch (e) {
      print('Error creating session: $e');
      return null;
    }
  }

  // Complete calibration and finalize user entry
  static Future<bool> completeCalibration() async {
    try {
      final sessionId = await getSessionId();
      if (sessionId == null) {
        print('No active session found');
        return false;
      }

      final response = await http.post(
        Uri.parse('${AppConfig.backendBaseUrl}/user_entry/complete_calibration'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'session_id': sessionId}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        
        if (result['status'] == 'calibration_completed') {
          // Clear session from local storage
          await clearSession();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error completing calibration: $e');
      return false;
    }
  }

  // Get session status
  static Future<UserSessionModel?> getSessionStatus() async {
    try {
      final sessionId = await getSessionId();
      if (sessionId == null) return null;

      final response = await http.get(
        Uri.parse('${AppConfig.backendBaseUrl}/user_entry/session/$sessionId'),
      );

      if (response.statusCode == 200) {
        return UserSessionModel.fromJson(jsonDecode(response.body));
      } else {
        // Session expired or invalid, clear it
        await clearSession();
        return null;
      }
    } catch (e) {
      print('Error getting session status: $e');
      await clearSession(); // Clear invalid session
      return null;
    }
  }
}
