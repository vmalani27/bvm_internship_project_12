import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MeasurementStepModel extends ChangeNotifier {
  final String category;
  int _currentStep = 0;
  bool _isSummary = false;
  final Map<String, String> _measurements = {};
  Player? _player;
  VideoController? _controllerVideo;

  MeasurementStepModel({required this.category}) {
    _initializeVideoForStep();
  }

  int get currentStep => _currentStep;
  bool get isSummary => _isSummary;
  Map<String, String> get measurements => _measurements;
  VideoController? get controllerVideo => _controllerVideo;

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

  String get currentField => steps[_currentStep]['field'];

  Future<void> _initializeVideoForStep() async {
    try {
      await _player?.dispose();
      final videoUrl = _getVideoUrlForStep();
      if (videoUrl.isEmpty) {
        _controllerVideo = null;
        notifyListeners();
        return;
      }
      _player = Player();
      _controllerVideo = VideoController(_player!);
      await _player!.open(Media(videoUrl));
      notifyListeners();
    } catch (e, stacktrace) {
      print('Error initializing video: $e');
      print('Stacktrace: $stacktrace');
      _controllerVideo = null;
      notifyListeners();
    }
  }

  String _getVideoUrlForStep() {
    if (_currentStep >= steps.length) {
      return '';
    }
    final step = steps[_currentStep];
    String filename = '';
    if (category == 'shaft') {
      if (step['field'] == 'shaft_height') filename = 'height of shaft.mkv';
      else if (step['field'] == 'shaft_radius') filename = 'radius of shaft.mkv';
      return 'http://127.0.0.1:8000/video/shaft/$filename';
    } else {
      // Use the typo filename to match backend expectation
      if (step['field'] == 'housing_height') filename = 'height of hosuing.mp4';
      else if (step['field'] == 'housing_radius') filename = 'radius of housing.mp4';
      else if (step['field'] == 'housing_depth') filename = 'depth of housing.mp4';
      return 'http://127.0.0.1:8000/video/housing/$filename';
    }
  }

  void nextStep(String inputValue) {
    _measurements[steps[_currentStep]['field']] = inputValue.trim();
    if (_currentStep < steps.length - 1) {
      _currentStep++;
      _initializeVideoForStep();
    } else {
      _isSummary = true;
    }
    notifyListeners();
  }

  void prevStep() {
    if (_currentStep > 0) {
      _currentStep--;
      _initializeVideoForStep();
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
    _player?.dispose();
    super.dispose();
  }
}
