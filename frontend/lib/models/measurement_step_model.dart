import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../services/api_service.dart';
import 'dart:developer' as developer;

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
  VideoController? get videoController =>
      _videoController; // media_kit VideoController getter
  bool get isVideoLoading => _isVideoLoading;

  List<Map<String, dynamic>> get steps {
    if (category == 'shaft') {
      return [
        {
          'label': 'Measure the height of the shaft',
          'icon': Icons.height,
          'field': 'shaft_height',
          'hint':
              'To measure the height, extend the depth bar, place the base on one end, and insert the depth bar until it touches the other end. Read the value from the scale.',
        },
        {
          'label': 'Measure the radius of the shaft',
          'icon': Icons.radio_button_checked,
          'field': 'shaft_radius',
          'hint':
              'To measure the radius, close the jaws around the shaft. Make sure the jaws are aligned and read the measurement from the scale.',
        },
      ];
    } else {
      // Housing types now have only 2 steps: height and radius
      return [
        {
          'label': 'Measure the height of the housing',
          'icon': Icons.height,
          'field': 'housing_height',
          'hint':
              'To measure the height, extend the depth bar, place the base on one end, and insert the depth bar until it touches the other end. Read the value from the scale.',
        },
        {
          'label': 'Measure the radius of the housing',
          'icon': Icons.radio_button_checked,
          'field': 'housing_radius',
          'hint':
              'To measure the radius, close the jaws around the housing. Make sure the jaws are aligned and read the measurement from the scale.',
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
    developer.log(
      'Category: $category, Step: $_currentStep, Summary: $_isSummary',
    );

    _isVideoLoading = true;
    notifyListeners();

    await _player?.dispose();
    _player = null;
    _videoController = null;

    if (_isSummary || _currentStep >= steps.length) {
      _isVideoLoading = false;
      notifyListeners();
      return;
    }

    try {
      final step = steps[_currentStep];
      String filename = '';
      String videoCategory = '';

      if (category == 'shaft') {
        videoCategory = 'shaft';
        if (step['field'] == 'shaft_height') {
          filename = 'shaft_height.mkv';
        } else if (step['field'] == 'shaft_radius') {
          filename = 'shaft_radius.mkv';
        }
      } else {
        videoCategory = '${category}_housing';
        if (step['field'] == 'housing_height') {
          filename =
              category == 'sqaure'
                  ? 'square_housing_depth.mkv'
                  : '${category}_housing_depth.mkv';
        } else if (step['field'] == 'housing_radius') {
          filename = '${category}_housing_radius.mkv';
        }
      }

      if (filename.isEmpty) {
        developer.log('No filename resolved for step ${step['field']}');
        _isVideoLoading = false;
        notifyListeners();
        return;
      }

      // Fetch a fresh presigned URL from the backend /play endpoint
      final presignedUrl = await ApiService.getPresignedVideoUrl(
        category: videoCategory,
        filename: filename,
      );

      if (presignedUrl == null || presignedUrl.isEmpty) {
        developer.log(
          'No presigned URL returned for $filename in $videoCategory',
        );
        _isVideoLoading = false;
        notifyListeners();
        return;
      }

      developer.log('Opening player with presigned URL: $presignedUrl');
      _player = Player();
      _videoController = VideoController(_player!);
      await _player!.open(Media(presignedUrl));

      developer.log('Player initialized successfully');
    } catch (e, stacktrace) {
      developer.log('Error initializing player: $e');
      developer.log('Stacktrace: $stacktrace');
      _player = null;
      _videoController = null;
    } finally {
      _isVideoLoading = false;
      notifyListeners();
    }
  }

  void nextStep(String inputValue) {
    if (_currentStep < steps.length) {
      _measurements[steps[_currentStep]['field']] = inputValue.trim();
    }

    if (_currentStep < steps.length - 1) {
      _currentStep++;
    } else {
      showSummary();
    }
    _initializeVideoForStep();
    notifyListeners();
  }

  void prevStep() {
    if (_currentStep > 0) {
      _isSummary = false;
      _currentStep--;
      _initializeVideoForStep(); // Re-initialize video for the previous step
      notifyListeners();
    }
  }

  // Public getter for isSummary
  bool get isSummaryState => _isSummary;

  // Add setter for isSummary
  set isSummary(bool value) {
    _isSummary = value;
    notifyListeners();
  }

  // Method to set summary state
  void showSummary() {
    _isSummary = true;
    notifyListeners();
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
