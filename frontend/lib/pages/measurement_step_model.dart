import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../config/app_config.dart';
import '../user_session.dart';
import 'dart:developer' as developer;
import 'dart:convert';
import 'package:http/http.dart' as http;


class MeasurementStepModel extends ChangeNotifier {
  final String category;
  final String? userRoll;
  final String? userName;
  String? productId;
  int _currentStep = 0;
  bool _isSummary = false;
  final Map<String, String> _measurements = {};
  Player? _player; // Changed back to media_kit Player
  VideoController? _videoController; // media_kit video controller
  bool _isVideoLoading = false;

  MeasurementStepModel({
    required this.category,
    this.userRoll,
    this.userName,
    this.productId,
  }) {
    _initializeVideoForStep();
  }

  int get currentStep => _currentStep;
  bool get isSummary => _isSummary;
  Map<String, String> get measurements => _measurements;
  Player? get player => _player; // media_kit Player getter
  VideoController? get videoController => _videoController; // media_kit VideoController getter
  bool get isVideoLoading => _isVideoLoading;

  /// Submit measurements to backend
  Future<bool> submitMeasurements() async {
    String endpoint;
    final body = Map<String, dynamic>.from(measurements);
    // Always include roll_number and name if available from session or model
    final roll = userRoll ?? UserSession.rollNumber;
    final name = userName ?? UserSession.name;
    final productIdValue = productId;
    if (roll != null && roll.isNotEmpty) body['roll_number'] = roll;
    if (name != null && name.isNotEmpty) body['name'] = name;
    if (productIdValue != null && productIdValue.isNotEmpty) body['product_id'] = productIdValue;
    if (category == 'shaft') {
      endpoint = '/shaft_measurement';
    } else {
      endpoint = '/housing_measurement';
    }
    final url = Uri.parse('${AppConfig.backendBaseUrl}$endpoint');
    developer.log('Submitting measurements: ' + jsonEncode(body));
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      developer.log('Backend response: ${response.statusCode} ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      developer.log('Error submitting measurements: $e');
      return false;
    }
  }

  List<Map<String, dynamic>> get steps {
    if (category == 'shaft') {
      return [
        {
          'label': 'Measure the height of the shaft',
          'icon': Icons.height,
          'field': 'shaft_height',
          'hint': 'Enter shaft height (mm)',
        },
        {
          'label': 'Measure the radius of the shaft',
          'icon': Icons.radio_button_checked,
          'field': 'shaft_radius',
          'hint': 'Enter shaft radius (mm)',
        },
      ];
    } else {
      return [
        {
          'label': 'Measure the height of the housing',
          'icon': Icons.height,
          'field': 'housing_height',
          'hint': 'Enter housing height (mm)',
        },
        {
          'label': 'Measure the radius of the housing',
          'icon': Icons.radio_button_checked,
          'field': 'housing_radius',
          'hint': 'Enter housing radius (mm)',
        },
        {
          'label': 'Measure the depth of the housing',
          'icon': Icons.vertical_align_bottom,
          'field': 'housing_depth',
          'hint': 'Enter housing depth (mm)',
        },
      ];
    }
  }

  String get currentField {
    if (_currentStep >= steps.length) {
      return '';
    }
    return steps[_currentStep]['field'];
  }

  Future<void> _initializeVideoForStep() async {
    developer.log('=== _initializeVideoForStep called ===');
    developer.log('Category: $category');
    developer.log('Current step: $_currentStep');
    developer.log('Is summary: $_isSummary');
    
    _isVideoLoading = true;
    notifyListeners(); // Notify to show loading indicator

    // Dispose previous player if it exists
    developer.log('Disposing previous player');
    await _player?.dispose();
    _player = null;
    _videoController = null;

    if (_isSummary) {
      developer.log('Is summary, no video needed');
      _isVideoLoading = false; // No video for summary
      notifyListeners();
      return;
    }

    try {
      final videoUrl = _getVideoUrlForStep();
      developer.log('Video URL: $videoUrl');
      if (videoUrl.isEmpty) {
        developer.log('Video URL is empty');
        _isVideoLoading = false;
        notifyListeners();
        return;
      }

      developer.log('Creating media_kit Player');
      // Initialize media_kit Player
      _player = Player();
      _videoController = VideoController(_player!);

      developer.log('Opening media with URL: $videoUrl');
      await _player!.open(Media(videoUrl));
      
      developer.log('Player initialized successfully');
      _isVideoLoading = false;
      notifyListeners();

    } catch (e, stacktrace) {
      developer.log('Error setting up media_kit player: $e');
      developer.log('Stacktrace: $stacktrace');
      _player = null;
      _videoController = null;
      _isVideoLoading = false; // Clear loading state on error
      notifyListeners();
    }
  }

  String _getVideoUrlForStep() {
    if (_currentStep >= steps.length) {
      return ''; // No video for summary
    }
    final step = steps[_currentStep];
    String filename = '';
    if (category == 'shaft') {
      if (step['field'] == 'shaft_height') filename = 'height of shaft.mkv';
      else if (step['field'] == 'shaft_radius') filename = 'radius of shaft.mkv';
      return '${AppConfig.backendBaseUrl}/video/shaft/${Uri.encodeComponent(filename)}';
    } else {
      if (step['field'] == 'housing_height') filename = 'height of hosuing.mp4';
      else if (step['field'] == 'housing_radius') filename = 'radius of housing.mp4';
      else if (step['field'] == 'housing_depth') filename = 'depth of housing.mp4';
      return '${AppConfig.backendBaseUrl}/video/housing/${Uri.encodeComponent(filename)}';
    }
  }

  void nextStep(String inputValue) {
    if (_currentStep < steps.length) {
      _measurements[steps[_currentStep]['field']] = inputValue.trim();
    }

    if (_currentStep < steps.length - 1) {
      _currentStep++;
    } else {
      _isSummary = true;
    }
    _initializeVideoForStep(); // Re-initialize video for the new step/summary
    notifyListeners(); // Notify for step change
  }

  void prevStep() {
    if (_currentStep > 0) {
      _isSummary = false;
      _currentStep--;
      _initializeVideoForStep(); // Re-initialize video for the previous step
      notifyListeners();
    }
  }

  void reset() {
    _currentStep = 0;
    _isSummary = false;
    _measurements.clear();
    _initializeVideoForStep();
    notifyListeners();
  }

  @override
  void dispose() {
    _player?.dispose(); // Dispose of media_kit Player
    super.dispose();
  }
}
