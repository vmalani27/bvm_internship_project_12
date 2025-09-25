import 'dart:convert';
// import 'dart:io';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/login_response.dart';
import '../models/user_session_model.dart';

// Custom exceptions for better error handling
class SessionException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  SessionException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'SessionException: $message${code != null ? ' (Code: $code)' : ''}';
}

class NetworkException extends SessionException {
  NetworkException(super.message, {super.code, super.originalError});
}

class SessionService {
  static const Duration _defaultTimeout = Duration(seconds: 8);
  static const Map<String, String> _jsonHeaders = {'Content-Type': 'application/json'};

  // Toggle verbose logging
  static bool debug = true;
  
  // In-memory session storage (no persistence)
  static String? _currentSessionId;

  static void _log(String msg) {
    if (debug) {
      print('[SessionService] $msg');
    }
  }

  // Store session ID in memory
  static Future<void> storeSessionId(String sessionId) async {
    _log('storeSessionId: Storing sessionId=$sessionId');
    
    if (sessionId.isEmpty) {
      throw SessionException('Session ID cannot be empty', code: 'EMPTY_SESSION_ID');
    }
    
    _currentSessionId = sessionId;
    _log('storeSessionId: Successfully stored session ID in memory');
  }

  // Get stored session ID from memory
  static Future<String?> getSessionId() async {
    _log('getSessionId: Retrieved sessionId=$_currentSessionId');
    return _currentSessionId;
  }

  // Clear session ID from memory
  static Future<void> clearSession() async {
    _log('clearSession: Clearing stored session ID');
    _currentSessionId = null;
    _log('clearSession: Successfully cleared session ID from memory');
  }

  // Check if user has active session
  static Future<bool> hasActiveSession() async {
    final sessionId = await getSessionId();
    return sessionId != null && sessionId.isNotEmpty;
  }

  // Create user session (login) with comprehensive error handling
  static Future<LoginResponse?> createUserSession({
    required String rollNumber,
    required String name,
  }) async {
    _log('createUserSession: Starting with rollNumber=$rollNumber name=$name');
    
    // Input validation
    if (rollNumber.trim().isEmpty) {
      throw SessionException('Roll number cannot be empty', code: 'INVALID_ROLL_NUMBER');
    }
    if (name.trim().isEmpty) {
      throw SessionException('Name cannot be empty', code: 'INVALID_NAME');
    }
    
    try {
      final uri = Uri.parse('${AppConfig.backendBaseUrl}/user_entry');
      final requestBody = {
        'roll_number': rollNumber.trim(),
        'name': name.trim(),
      };
      
      _log('createUserSession: Making POST request to $uri');
      _log('createUserSession: Request body: $requestBody');
      
      final response = await http.post(
        uri,
        headers: _jsonHeaders,
        body: jsonEncode(requestBody),
      ).timeout(_defaultTimeout);
      
      _log('createUserSession: Response status: ${response.statusCode}');
      _log('createUserSession: Response headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        _log('createUserSession: Response body: ${response.body}');
        
        if (response.body.isEmpty) {
          throw SessionException('Empty response body from server', code: 'EMPTY_RESPONSE');
        }
        
        final Map<String, dynamic> parsed;
        try {
          parsed = jsonDecode(response.body);
        } catch (e) {
          throw SessionException(
            'Failed to parse server response as JSON',
            code: 'JSON_PARSE_ERROR',
            originalError: e,
          );
        }
        
        final LoginResponse loginResponse;
        try {
          loginResponse = LoginResponse.fromJson(parsed);
        } catch (e) {
          throw SessionException(
            'Failed to create LoginResponse from JSON',
            code: 'MODEL_PARSE_ERROR',
            originalError: e,
          );
        }
        
        _log('createUserSession: LoginResponse created, storing session ID');
        
        try {
          await storeSessionId(loginResponse.sessionId);
        } catch (e) {
          _log('createUserSession: Failed to store session ID, but continuing: $e');
          // Don't fail the entire operation if storage fails
        }
        
        return loginResponse;
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        // Client error
        String errorMessage = 'Client error: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          errorMessage += ' - ${response.body}';
        }
        throw NetworkException(errorMessage, code: 'CLIENT_ERROR_${response.statusCode}');
      } else if (response.statusCode >= 500) {
        // Server error
        throw NetworkException(
          'Server error: ${response.statusCode}',
          code: 'SERVER_ERROR_${response.statusCode}',
        );
      } else {
        throw NetworkException(
          'Unexpected response status: ${response.statusCode}',
          code: 'UNEXPECTED_STATUS_${response.statusCode}',
        );
      }
    } on TimeoutException catch (e, stackTrace) {
      _log('createUserSession: Timeout exception: $e');
      _log('createUserSession: Stack trace: $stackTrace');
      throw NetworkException(
        'Request timed out after ${_defaultTimeout.inSeconds} seconds',
        code: 'TIMEOUT',
        originalError: e,
      );
    } catch (e, stackTrace) {
      _log('createUserSession: Network exception: $e');
      _log('createUserSession: Stack trace: $stackTrace');
      throw NetworkException(
        'Network error: $e',
        originalError: e,
      );
    }
  }

  // Complete calibration and finalize user entry with proper error handling
  static Future<bool> completeCalibration() async {
    _log('completeCalibration: Starting calibration completion');
    
    try {
      final sessionId = await getSessionId();
      if (sessionId == null) {
        _log('completeCalibration: No active session found');
        throw SessionException('No active session found', code: 'NO_ACTIVE_SESSION');
      }

      final uri = Uri.parse('${AppConfig.backendBaseUrl}/user_entry/complete_calibration');
      final requestBody = {'session_id': sessionId};
      
      _log('completeCalibration: Making POST request to $uri');
      _log('completeCalibration: Request body: $requestBody');
      
      final response = await http.post(
        uri,
        headers: _jsonHeaders,
        body: jsonEncode(requestBody),
      ).timeout(_defaultTimeout);

      _log('completeCalibration: Response status: ${response.statusCode}');
      _log('completeCalibration: Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw SessionException('Empty response body from server', code: 'EMPTY_RESPONSE');
        }
        
        final Map<String, dynamic> result;
        try {
          result = jsonDecode(response.body);
        } catch (e) {
          throw SessionException(
            'Failed to parse server response as JSON',
            code: 'JSON_PARSE_ERROR',
            originalError: e,
          );
        }
        
        if (result['status'] == 'calibration_completed') {
          try {
            await clearSession();
            _log('completeCalibration: Successfully completed and cleared session');
            return true;
          } catch (e) {
            _log('completeCalibration: Calibration completed but failed to clear session: $e');
            // Still return true since calibration was successful
            return true;
          }
        } else {
          _log('completeCalibration: Unexpected status in response: ${result['status']}');
          throw SessionException(
            'Unexpected calibration status: ${result['status']}',
            code: 'UNEXPECTED_CALIBRATION_STATUS',
          );
        }
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        String errorMessage = 'Client error: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          errorMessage += ' - ${response.body}';
        }
        throw NetworkException(errorMessage, code: 'CLIENT_ERROR_${response.statusCode}');
      } else {
        throw NetworkException(
          'Server error: ${response.statusCode}',
          code: 'SERVER_ERROR_${response.statusCode}',
        );
      }
    } on TimeoutException catch (e, stackTrace) {
      _log('completeCalibration: Timeout exception: $e');
      _log('completeCalibration: Stack trace: $stackTrace');
      throw NetworkException(
        'Request timed out after ${_defaultTimeout.inSeconds} seconds',
        code: 'TIMEOUT',
        originalError: e,
      );
    } on SessionException {
      rethrow;
    } catch (e, stackTrace) {
      _log('completeCalibration: Unexpected exception: $e');
      _log('completeCalibration: Stack trace: $stackTrace');
      throw SessionException(
        'Failed to complete calibration: ${e.toString()}',
        code: 'UNKNOWN_ERROR',
        originalError: e,
      );
    }
  }

  // Get session status with comprehensive error handling
  static Future<UserSessionModel?> getSessionStatus() async {
    _log('getSessionStatus: Retrieving session status');
    
    try {
      final sessionId = await getSessionId();
      if (sessionId == null) {
        _log('getSessionStatus: No session ID found');
        return null;
      }

      final uri = Uri.parse('${AppConfig.backendBaseUrl}/user_entry/session/$sessionId');
      _log('getSessionStatus: Making GET request to $uri');
      
      final response = await http.get(uri).timeout(_defaultTimeout);

      _log('getSessionStatus: Response status: ${response.statusCode}');
      _log('getSessionStatus: Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw SessionException('Empty response body from server', code: 'EMPTY_RESPONSE');
        }
        
        final Map<String, dynamic> parsed;
        try {
          parsed = jsonDecode(response.body);
        } catch (e) {
          throw SessionException(
            'Failed to parse server response as JSON',
            code: 'JSON_PARSE_ERROR',
            originalError: e,
          );
        }
        
        try {
          return UserSessionModel.fromJson(parsed);
        } catch (e) {
          throw SessionException(
            'Failed to create UserSessionModel from JSON',
            code: 'MODEL_PARSE_ERROR',
            originalError: e,
          );
        }
      } else if (response.statusCode == 404) {
        // Session not found or expired
        _log('getSessionStatus: Session not found (404), clearing local session');
        try {
          await clearSession();
        } catch (e) {
          _log('getSessionStatus: Failed to clear session after 404: $e');
        }
        return null;
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        // Other client errors - also clear session
        _log('getSessionStatus: Client error ${response.statusCode}, clearing session');
        try {
          await clearSession();
        } catch (e) {
          _log('getSessionStatus: Failed to clear session after client error: $e');
        }
        
        String errorMessage = 'Session validation failed: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          errorMessage += ' - ${response.body}';
        }
        throw NetworkException(errorMessage, code: 'CLIENT_ERROR_${response.statusCode}');
      } else {
        throw NetworkException(
          'Server error: ${response.statusCode}',
          code: 'SERVER_ERROR_${response.statusCode}',
        );
      }
    } on TimeoutException catch (e, stackTrace) {
      _log('getSessionStatus: Timeout exception: $e');
      _log('getSessionStatus: Stack trace: $stackTrace');
      throw NetworkException(
        'Request timed out after ${_defaultTimeout.inSeconds} seconds',
        code: 'TIMEOUT',
        originalError: e,
      );
    } on SessionException {
      rethrow;
    } catch (e, stackTrace) {
      _log('getSessionStatus: Unexpected exception: $e');
      _log('getSessionStatus: Stack trace: $stackTrace');
      
      // Clear session on any unexpected error
      try {
        await clearSession();
      } catch (clearError) {
        _log('getSessionStatus: Failed to clear session after error: $clearError');
      }
      
      throw SessionException(
        'Failed to get session status: ${e.toString()}',
        code: 'UNKNOWN_ERROR',
        originalError: e,
      );
    }
  }
}
