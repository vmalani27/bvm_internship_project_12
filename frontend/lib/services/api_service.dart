import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 30);

  /// Get list of available housing types
  static Future<List<String>> getHousingTypes() async {
    try {
      developer.log('[API] Fetching housing types');
      final response = await http
          .get(
            Uri.parse('${AppConfig.backendBaseUrl}/housing_types'),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> types = data['housing_types'];
        developer.log('[API] Housing types received: $types');
        return types.cast<String>();
      } else {
        developer.log('[API] Error fetching housing types: ${response.statusCode}');
        throw Exception('Failed to load housing types: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('[API] Exception in getHousingTypes: $e');
      rethrow;
    }
  }

  /// Get list of videos for a specific housing type
  static Future<List<String>> getHousingVideos(String housingType) async {
    try {
      developer.log('[API] Fetching videos for housing type: $housingType');
      final response = await http
          .get(
            Uri.parse('${AppConfig.backendBaseUrl}/video/housing_types/$housingType'),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> videos = json.decode(response.body);
        developer.log('[API] Videos for $housingType: $videos');
        return videos.cast<String>();
      } else {
        developer.log('[API] Error fetching videos for $housingType: ${response.statusCode}');
        throw Exception('Failed to load videos for $housingType: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('[API] Exception in getHousingVideos: $e');
      rethrow;
    }
  }

  /// Get list of videos for shaft category
  static Future<List<String>> getShaftVideos() async {
    try {
      developer.log('[API] Fetching shaft videos');
      final response = await http
          .get(
            Uri.parse('${AppConfig.backendBaseUrl}/video/list/shaft'),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> videos = json.decode(response.body);
        developer.log('[API] Shaft videos: $videos');
        return videos.cast<String>();
      } else {
        developer.log('[API] Error fetching shaft videos: ${response.statusCode}');
        throw Exception('Failed to load shaft videos: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('[API] Exception in getShaftVideos: $e');
      rethrow;
    }
  }

  /// Submit measurement data
  static Future<bool> submitMeasurement({
    required String category,
    required String productId,
    required Map<String, String> measurements,
    String? housingType,
  }) async {
    try {
      developer.log('[API] Submitting measurement for $category');
      developer.log('[API] Product ID: $productId');
      developer.log('[API] Housing type: $housingType');
      developer.log('[API] Measurements: $measurements');

      String endpoint;
      Map<String, dynamic> requestBody;

      if (category == 'shaft') {
        endpoint = '/shaft_measurement';
        requestBody = {
          'product_id': productId,
          'roll_number': measurements['roll_number'] ?? '',
          'shaft_height': measurements['shaft_height'] ?? '',
          'shaft_radius': measurements['shaft_radius'] ?? '',
        };
      } else {
        // Housing measurement
        endpoint = '/housing_measurement';
        requestBody = {
          'product_id': productId,
          'roll_number': measurements['roll_number'] ?? '',
          'housing_type': housingType ?? category,
          'housing_height': measurements['housing_height'] ?? '',
          'housing_radius': measurements['housing_radius'] ?? '',
          // housing_depth will be set to housing_height by the backend if not provided
        };
      }

      developer.log('[API] Request body: $requestBody');

      final response = await http
          .post(
            Uri.parse('${AppConfig.backendBaseUrl}$endpoint'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(requestBody),
          )
          .timeout(_timeout);

      developer.log('[API] Submission response: ${response.statusCode}');
      developer.log('[API] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['status'] == 'shaft measurement added' || 
               result['status'] == 'housing measurement added';
      } else {
        developer.log('[API] Error submitting measurement: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      developer.log('[API] Exception in submitMeasurement: $e');
      return false;
    }
  }

  /// Test backend connection
  static Future<bool> testConnection() async {
    try {
      developer.log('[API] Testing backend connection');
      final response = await http
          .get(
            Uri.parse('${AppConfig.backendBaseUrl}/housing_types'),
          )
          .timeout(_timeout);

      final isConnected = response.statusCode == 200;
      developer.log('[API] Backend connection test: ${isConnected ? 'SUCCESS' : 'FAILED'}');
      return isConnected;
    } catch (e) {
      developer.log('[API] Backend connection test failed: $e');
      return false;
    }
  }

  /// Get video URL for direct streaming
  static String getVideoUrl(String category, String filename) {
    final url = '${AppConfig.backendBaseUrl}/video/$category/${Uri.encodeComponent(filename)}';
    developer.log('[API] Generated video URL: $url');
    return url;
  }

  /// Check if a video exists before trying to load it
  static Future<bool> checkVideoExists(String category, String filename) async {
    try {
      final response = await http
          .head(Uri.parse(getVideoUrl(category, filename)))
          .timeout(const Duration(seconds: 10));
      
      final exists = response.statusCode == 200 || response.statusCode == 206;
      developer.log('[API] Video exists check for $filename in $category: $exists');
      return exists;
    } catch (e) {
      developer.log('[API] Error checking video existence: $e');
      return false;
    }
  }
}
