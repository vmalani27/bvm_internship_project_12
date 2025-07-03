import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MeasurementStepPage extends StatefulWidget {
  final String category;
  const MeasurementStepPage({required this.category, super.key});

  @override
  State<MeasurementStepPage> createState() => _MeasurementStepPageState();
}

class _MeasurementStepPageState extends State<MeasurementStepPage> {
  int _currentStep = 0;
  final Map<String, String> _measurements = {};
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  Player? _player;
  VideoController? _controllerVideo;

  List<Map<String, dynamic>> get steps {
    if (widget.category == 'shaft') {
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

  @override
  void initState() {
    super.initState();
    _initVideoForStep();
  }

  @override
  void didUpdateWidget(covariant MeasurementStepPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initVideoForStep();
  }

  void _initVideoForStep() async {
    await _player?.dispose();
    final videoUrl = _getVideoUrlForStep();
    _player = Player();
    _controllerVideo = VideoController(_player!);
    _player!.open(Media(videoUrl));
    setState(() {});
  }

  String _getVideoUrlForStep() {
    final step = steps[_currentStep];
    String filename = '';
    if (widget.category == 'shaft') {
      if (step['field'] == 'shaft_height') filename = 'height of shaft.mkv';
      else if (step['field'] == 'shaft_radius') filename = 'radius of shaft.mkv';
      return 'http://127.0.0.1:8000/video/shaft/$filename';
    } else {
      if (step['field'] == 'housing_height') filename = 'height of hosuing.mp4';
      else if (step['field'] == 'housing_radius') filename = 'radius of housing.mp4';
      else if (step['field'] == 'housing_depth') filename = 'depth of housing.mp4';
      return 'http://127.0.0.1:8000/video/housing/$filename';
    }
  }

  void _nextStep() {
    if (_formKey.currentState?.validate() ?? false) {
      _measurements[steps[_currentStep]['field']] = _controller.text.trim();
      if (_currentStep < steps.length - 1) {
        setState(() {
          _currentStep++;
          _controller.text = _measurements[steps[_currentStep]['field']] ?? '';
          _initVideoForStep();
        });
      } else {
        setState(() {
          _currentStep++;
        });
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _controller.text = _measurements[steps[_currentStep]['field']] ?? '';
        _initVideoForStep();
      });
    }
  }

  void _showStepInfoDialog(BuildContext context) {
    final step = steps[_currentStep];
    String infoText = '';
    if (step['field'] == 'shaft_height' || step['field'] == 'housing_height') {
      infoText = '''To measure the height:

1. Extend the depth bar (the thin rod at the end of the Vernier caliper) by sliding the movable jaw.
2. Place the base of the caliper on one end of the object and insert the depth bar until it touches the other end.
3. Read the measurement from the main and vernier scales.''';
    } else if (step['field'] == 'shaft_radius' || step['field'] == 'housing_radius') {
      infoText = '''To measure the radius:

1. Open the Vernier caliper.
2. Place the inside jaws inside the circular opening of the shaft/housing.
3. Gently expand the jaws until they touch the inner walls.
4. Read the measurement from the main and vernier scales.''';
    } else if (step['field'] == 'housing_depth') {
      infoText = '''To measure the depth:

1. Extend the depth rod (the thin rod at the end of the Vernier caliper) by sliding the movable jaw.
2. Insert the depth rod into the hole or cavity until the base of the caliper rests flat on the surface.
3. Read the measurement from the main and vernier scales.''';
    } else {
      infoText = 'Follow the instructions for this measurement.';
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Measurement Info'),
        content: Text(infoText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSummary = _currentStep >= steps.length;
    final totalSteps = steps.length;
    return Scaffold(
      appBar: AppBar(
        title: Text('Manual Measurement (${widget.category[0].toUpperCase()}${widget.category.substring(1)})'),
        centerTitle: true,
      ),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: Card(
            key: ValueKey(_currentStep),
            elevation: 8,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
              child: isSummary
                  ? _buildSummary(context)
                  : Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Step ${_currentStep + 1} of $totalSteps',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              if (_controllerVideo != null)
                                Icon(Icons.play_circle_fill, color: Theme.of(context).colorScheme.primary, size: 28),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_controllerVideo != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: SizedBox(
                                height: 320,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Video(controller: _controllerVideo!),
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  steps[_currentStep]['label'],
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.info_outline),
                                tooltip: 'More info',
                                onPressed: () => _showStepInfoDialog(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _controller,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: steps[_currentStep]['hint'],
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a value';
                              }
                              final numValue = num.tryParse(value.trim());
                              if (numValue == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (_currentStep > 0)
                                OutlinedButton(
                                  onPressed: _prevStep,
                                  child: const Text('Back'),
                                ),
                              ElevatedButton(
                                onPressed: _nextStep,
                                child: Text(_currentStep == steps.length - 1 ? 'Review' : 'Next'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, size: 48, color: Colors.green),
        const SizedBox(height: 16),
        const Text('Review Your Measurements', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 18),
        ...steps.map((step) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(step['label'], style: const TextStyle(fontSize: 16)),
                  Text(_measurements[step['field']] ?? '-', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            )),
        const SizedBox(height: 28),
        ElevatedButton.icon(
          icon: const Icon(Icons.send),
          label: const Text('Submit Measurements'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () {
            // TODO: Implement submission logic
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Measurements submitted!')),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ],
    );
  }
} 