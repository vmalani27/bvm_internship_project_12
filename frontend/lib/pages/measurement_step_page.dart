import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'measurement_step_model.dart';

class MeasurementStepPage extends StatefulWidget {
  final String category;
  const MeasurementStepPage({required this.category, super.key});

  @override
  State<MeasurementStepPage> createState() => _MeasurementStepPageState();
}

class _MeasurementStepPageState extends State<MeasurementStepPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MeasurementStepModel>(
      create: (_) => MeasurementStepModel(category: widget.category),
      child: Consumer<MeasurementStepModel>(
        builder: (context, model, child) {
          if (!model.isSummary) {
            _controller.text = model.measurements[model.currentField] ?? '';
          }
          final totalSteps = model.steps.length;
          return Scaffold(
            appBar: AppBar(
              title: Text('Measurement (${widget.category[0].toUpperCase()}${widget.category.substring(1)})'),
              centerTitle: true,
            ),
            body: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: Card(
                  key: ValueKey('${model.isSummary ? 'summary' : 'step'}_${model.currentStep}'),
                  elevation: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
                    child: model.isSummary
                        ? _buildSummary(context, model)
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
                                      'Step ${model.currentStep + 1} of $totalSteps',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (model.controllerVideo != null)
                                      Icon(Icons.play_circle_fill,
                                          color: Theme.of(context).colorScheme.primary, size: 28),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (model.controllerVideo != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: SizedBox(
                                      height: 320,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Video(controller: model.controllerVideo!),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 24),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        model.steps[model.currentStep]['label'],
                                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.info_outline),
                                      tooltip: 'More info',
                                      onPressed: () => _showStepInfoDialog(context, model),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                TextFormField(
                                  key: ValueKey('input_${model.currentStep}'),
                                  controller: _controller,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    hintText: model.steps[model.currentStep]['hint'],
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
                                    if (model.currentStep > 0)
                                      OutlinedButton(
                                        onPressed: () {
                                          _formKey.currentState?.save();
                                          model.prevStep();
                                        },
                                        child: const Text('Back'),
                                      ),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState?.validate() ?? false) {
                                          model.nextStep(_controller.text);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Please enter a valid value for step ${model.currentStep + 1}')),
                                          );
                                        }
                                      },
                                      child: Text(model.currentStep == model.steps.length - 1 ? 'Review' : 'Next'),
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
        },
      ),
    );
  }

  void _showStepInfoDialog(BuildContext context, MeasurementStepModel model) {
    final step = model.steps[model.currentStep];
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

  Widget _buildSummary(BuildContext context, MeasurementStepModel model) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, size: 48, color: Colors.green),
        const SizedBox(height: 16),
        const Text('Review Your Measurements', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 18),
        ...model.steps.map((step) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(step['label'], style: const TextStyle(fontSize: 16)),
                  Text(model.measurements[step['field']] ?? '-', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
