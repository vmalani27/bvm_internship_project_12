import 'package:flutter/material.dart';
import 'measurement_step_model.dart';
import 'media_kit_video_player.dart';
import 'submission_result_page.dart';
import 'dart:developer' as developer;

class MeasurementStepPage extends StatefulWidget {
  final String category;
  final MeasurementStepModel model;

  const MeasurementStepPage({
    super.key,
    required this.category,
    required this.model,
  });

  @override
  State<MeasurementStepPage> createState() => _MeasurementStepPageState();
}

class _MeasurementStepPageState extends State<MeasurementStepPage> {
  final _formKey = GlobalKey<FormState>();
  final _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    developer.log('MeasurementStepPage initialized for category: ${widget.category}');
    developer.log('Initial step: ${widget.model.currentStep}');
    developer.log('Video controller status: ${widget.model.videoController != null ? "initialized" : "null"}');
    developer.log('Video loading status: ${widget.model.isVideoLoading}');
  }

  @override
  void dispose() {
    developer.log('MeasurementStepPage disposing');
    _inputController.dispose();
    super.dispose();
  }

  TextEditingController _productIdController = TextEditingController();
  bool _productIdSet = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category == 'housing' ? 'Housing' : 'Shaft'} Measurement'),
        backgroundColor: widget.category == 'housing' 
            ? const Color(0xFF1976D2) 
            : const Color(0xFF388E3C),
        foregroundColor: Colors.white,
      ),
      body: ListenableBuilder(
        listenable: widget.model,
        builder: (context, _) {
          if (!_productIdSet) {
            // Gemini/ChatGPT inspired theme colors
            const Color blue = Color(0xFF4F8CFF);
            const Color purple = Color(0xFF8B5CF6);
            const Color teal = Color(0xFF2DD4BF);
            const Color white = Colors.white;
            const Color bgGradientStart = Color(0xFFF5F7FA);
            const Color bgGradientEnd = Color(0xFFE8ECF7);
            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [bgGradientStart, bgGradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(36)),
                ),
                child: Card(
                  elevation: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  color: white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 44),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [blue.withOpacity(0.18), purple.withOpacity(0.18), teal.withOpacity(0.18)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Icon(Icons.bubble_chart_rounded, size: 54, color: purple),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Welcome to BVM Station',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: purple,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manual Inspection & Measurement',
                          style: TextStyle(
                            fontSize: 16,
                            color: blue.withOpacity(0.85),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: teal.withOpacity(0.13),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Icon(Icons.qr_code_2, size: 38, color: blue),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Enter Product ID to continue',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            color: blue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _productIdController,
                          style: const TextStyle(fontSize: 17, color: blue),
                          decoration: InputDecoration(
                            labelText: 'Product ID',
                            labelStyle: const TextStyle(color: purple, fontWeight: FontWeight.w500),
                            prefixIcon: const Icon(Icons.confirmation_number, color: teal),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(color: teal, width: 1.2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(color: purple, width: 2),
                            ),
                            filled: true,
                            fillColor: white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Continue'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: purple,
                              foregroundColor: white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 3,
                              shadowColor: purple.withOpacity(0.18),
                            ),
                            onPressed: () {
                              if (_productIdController.text.trim().isNotEmpty) {
                                setState(() {
                                  widget.model.productId = _productIdController.text.trim();
                                  _productIdSet = true;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          if (widget.model.isSummary) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: MeasurementSummaryWidget(model: widget.model),
            );
          }

          final currentStep = widget.model.steps[widget.model.currentStep];
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Step indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Step ${widget.model.currentStep + 1} of ${widget.model.steps.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Video player
                  Builder(
                    builder: (context) {
                      developer.log('Building MediaKitVideoPlayer widget');
                      developer.log('Player: ${widget.model.player}');
                      developer.log('VideoController: ${widget.model.videoController}');
                      developer.log('Is loading: ${widget.model.isVideoLoading}');
                      
                      try {
                        return MediaKitVideoPlayer(
                          player: widget.model.player,
                          videoController: widget.model.videoController,
                          isLoading: widget.model.isVideoLoading,
                        );
                      } catch (e, stackTrace) {
                        developer.log('Error creating MediaKitVideoPlayer: $e');
                        developer.log('Stack trace: $stackTrace');
                        return Container(
                          height: 300,
                          color: Colors.grey[300],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error, color: Colors.red, size: 48),
                                SizedBox(height: 16),
                                Text('Error loading video player'),
                                SizedBox(height: 8),
                                Text('$e', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Measurement input
                  MeasurementInputWidget(
                    label: currentStep['label'],
                    hint: currentStep['hint'],
                    controller: _inputController,
                    isLastStep: widget.model.currentStep == widget.model.steps.length - 1,
                    onNext: _onNext,
                    onBack: _onBack,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onNext() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.model.nextStep(_inputController.text);
      _inputController.clear();
    }
  }

  void _onBack() {
    widget.model.prevStep();
    // Load the previous measurement if available
    final field = widget.model.currentField;
    if (field.isNotEmpty && widget.model.measurements.containsKey(field)) {
      _inputController.text = widget.model.measurements[field] ?? '';
    }
  }
}

class MeasurementInputWidget extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isLastStep;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const MeasurementInputWidget({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.isLastStep,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
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
          key: ValueKey('input_${label}'),
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hint,
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
            if (!isLastStep)
              OutlinedButton(
                onPressed: onBack,
                child: const Text('Back'),
              ),
            ElevatedButton(
              onPressed: onNext,
              child: Text(isLastStep ? 'Review' : 'Next'),
            ),
          ],
        ),
      ],
    );
  }

  void _showStepInfoDialog(BuildContext context) {
    String infoText = '';
    if (label == 'Shaft Height' || label == 'Housing Height') {
      infoText = '''To measure the height:

1. Extend the depth bar (the thin rod at the end of the Vernier caliper) by sliding the movable jaw.
2. Place the base of the caliper on one end of the object and insert the depth bar until it touches the other end.
3. Read the measurement from the main and vernier scales.''';
    } else if (label == 'Shaft Radius' || label == 'Housing Radius') {
      infoText = '''To measure the radius:

1. Open the Vernier caliper.
2. Place the inside jaws inside the circular opening of the shaft/housing.
3. Gently expand the jaws until they touch the inner walls.
4. Read the measurement from the main and vernier scales.''';
    } else if (label == 'Housing Depth') {
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
}

class MeasurementSummaryWidget extends StatelessWidget {
  final MeasurementStepModel model;

  const MeasurementSummaryWidget({
    Key? key,
    required this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  Text(model.measurements[step['field']] ?? '-',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
          onPressed: () async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(child: CircularProgressIndicator()),
            );
            final success = await model.submitMeasurements();
            Navigator.of(context).pop(); // Remove loading dialog
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => SubmissionResultPage(success: success),
              ),
            );
          },
        ),
      ],
    );
  }
}
