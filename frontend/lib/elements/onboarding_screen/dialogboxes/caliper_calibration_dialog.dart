import 'package:flutter/material.dart';
import 'dart:async'; // For Timer
import '../../common_elements/common_flushbar.dart';
// A simple class to hold calibration results for each step
class CalibrationResult {
  final double target;
  final double actual;
  final double error; // Absolute difference

  CalibrationResult({required this.target, required this.actual, required this.error});
}

class CaliperCalibrationDialog extends StatefulWidget {
  const CaliperCalibrationDialog({super.key});

  @override
  State<CaliperCalibrationDialog> createState() => _CaliperCalibrationDialogState();
}

class _CaliperCalibrationDialogState extends State<CaliperCalibrationDialog> {
  // Define calibration steps (target measurements in mm)
  // You can adjust these values based on your requirements
  final List<double> _calibrationSteps = [0.00, 10.00, 25.00, 50.00, 100.00];
  int _currentStepIndex = 0;
  List<CalibrationResult> _results = [];

  final TextEditingController _caliperInputController = TextEditingController();
  final FocusNode _caliperFocusNode = FocusNode();
  Timer? _inputCompletionTimer; // Timer to detect pause in caliper input
  String? _currentCaliperInput; // Stores the raw input from caliper for the current step

  bool _isProcessingInput = false; // To prevent multiple processing attempts

  @override
  void initState() {
    super.initState();
    _caliperInputController.addListener(_handleCaliperInput);
    // Request focus for the hidden TextField when the dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_caliperFocusNode);
      _showInstructionSnackBar();
    });
  }

  @override
  void dispose() {
    _caliperInputController.removeListener(_handleCaliperInput);
    _caliperInputController.dispose();
    _caliperFocusNode.dispose();
    _inputCompletionTimer?.cancel();
    super.dispose();
  }

  void _showInstructionSnackBar() {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text('Set caliper to ${_calibrationSteps[_currentStepIndex].toStringAsFixed(2)} mm and press its data button.'),
    //     duration: const Duration(seconds: 5),
    //   ),
    // );

    showCustomFlushBar(context, 'Set caliper to ${_calibrationSteps[_currentStepIndex].toStringAsFixed(2)} mm and press its data button.');
  }

  void _handleCaliperInput() {
    String currentText = _caliperInputController.text;

    // Log raw input for debugging
    // ignore: avoid_print
    print('Calibration Dialog Raw input: "$currentText" (Length: ${currentText.length})');

    // Reset the input completion timer every time a character is received.
    _inputCompletionTimer?.cancel(); // Cancel previous timer
    _inputCompletionTimer = Timer(const Duration(milliseconds: 100), () {
      // This code runs if no new character is received for 100ms
      _processCaliperMeasurement(currentText);
    });
  }

  void _processCaliperMeasurement(String measurementText) {
    if (_isProcessingInput) return; // Prevent re-entry
    _isProcessingInput = true;

    // --- NEW: Return early if the input is empty or just whitespace ---
    if (measurementText.trim().isEmpty) {
      // ignore: avoid_print
      print('Calibration Dialog - Received empty input, skipping processing.');
      _isProcessingInput = false;
      return;
    }
    // --- END NEW ---

    String dimensionString = measurementText.trim();
    double? actualMeasurement = double.tryParse(dimensionString);

    // IMPORTANT: Clear and request focus AFTER processing,
    // so the field is ready for the NEXT set of characters.
    _caliperInputController.clear();
    _caliperFocusNode.requestFocus(); 

    if (actualMeasurement != null) {
      // Valid number received, store it temporarily
      setState(() {
        _currentCaliperInput = dimensionString;
      });
      // Log successful capture
      // ignore: avoid_print
      print('Calibration Dialog - Captured measurement: $actualMeasurement');
    } else {
      // Invalid input (e.g., partial number, non-numeric)
      setState(() {
        _currentCaliperInput = null; // Clear any invalid display
      });
      // Log invalid input
      // ignore: avoid_print
      print('Calibration Dialog - Invalid measurement received: "$dimensionString"');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid input from caliper. Please ensure it\'s a number.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
    _isProcessingInput = false;
  }

  void _nextStep() {
    if (_currentCaliperInput == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please take a measurement with the caliper first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    double actual = double.parse(_currentCaliperInput!);
    double target = _calibrationSteps[_currentStepIndex];
    double error = (target - actual).abs();

    setState(() {
      _results.add(CalibrationResult(target: target, actual: actual, error: error));
      _currentCaliperInput = null; // Clear for next step
      _currentStepIndex++;
    });

    if (_currentStepIndex < _calibrationSteps.length) {
      _showInstructionSnackBar(); // Show instruction for next step
      // Ensure focus is maintained for the next input
      _caliperFocusNode.requestFocus(); 
    } else {
      _finishCalibration(); // All steps completed
    }
  }

  void _finishCalibration() {
    // Calculate overall accuracy (e.g., average absolute error)
    double totalError = _results.fold(0.0, (sum, result) => sum + result.error);
    double averageError = totalError / _results.length;

    // You can define a threshold for "good" calibration here
    bool calibrationSuccessful = averageError < 0.05; // Example threshold

    // Pop the dialog with the success status
    Navigator.of(context).pop(calibrationSuccessful);
  }

  // Called when the user tries to close the dialog prematurely
  Future<bool> _onWillPop() async {
    if (_currentStepIndex < _calibrationSteps.length) {
      // Calibration not complete, show confirmation dialog
      final bool? confirmExit = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Calibration In Progress'),
            content: const Text(
                'Calibration is not complete. If you exit now, the calibration '
                'will not be saved. Do you want to continue and exit?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(false); // Don't exit
                },
              ),
              TextButton(
                child: const Text('Exit Anyway'),
                onPressed: () {
                  Navigator.of(context).pop(true); // Exit
                },
              ),
            ],
          );
        },
      );
      return confirmExit ?? false; // If dialog dismissed, don't exit
    }
    return true; // Calibration complete, allow exit
  }

  @override
  Widget build(BuildContext context) {
    bool calibrationComplete = _currentStepIndex >= _calibrationSteps.length;
    double targetMeasurement = calibrationComplete ? 0.0 : _calibrationSteps[_currentStepIndex];

    return PopScope( // Use PopScope for Android back button
      canPop: false, // Prevent popping directly
      onPopInvoked: (didPop) async {
        if (didPop) return; // If system pop already handled, do nothing
        final bool? shouldPop = await _onWillPop();
        if (shouldPop == true) {
          Navigator.of(context).pop(false); // Indicate calibration was cancelled
        }
      },
      child: AlertDialog(
        contentPadding: EdgeInsets.zero, // Remove default padding
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero, // Remove default title padding
        // Use a Builder to get a context for ScaffoldMessenger
        content: Builder(
          builder: (dialogContext) {
            return Container(
              width: MediaQuery.of(dialogContext).size.width * 0.8, // Adjust width
              height: MediaQuery.of(dialogContext).size.height * 0.7, // Adjust height
              constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Theme.of(dialogContext).colorScheme.primary,
                    foregroundColor: Theme.of(dialogContext).colorScheme.onPrimary,
                    title: const Text('Caliper Calibration'),
                    automaticallyImplyLeading: false, // No back button
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () async {
                          final bool? shouldPop = await _onWillPop();
                          if (shouldPop == true) {
                            Navigator.of(dialogContext).pop(false); // Indicate cancellation
                          }
                        },
                      ),
                    ],
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          LinearProgressIndicator(
                            value: _currentStepIndex / _calibrationSteps.length,
                            backgroundColor: Colors.grey.shade300,
                            color: Theme.of(dialogContext).colorScheme.primary,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Step ${_currentStepIndex + 1} of ${_calibrationSteps.length}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            calibrationComplete
                                ? 'Calibration Complete!'
                                : 'Please set the caliper to:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: calibrationComplete ? Colors.green : null,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (!calibrationComplete)
                            Text(
                              '${targetMeasurement.toStringAsFixed(2)} mm',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          const SizedBox(height: 20),
                          Text(
                            'Captured: ${_currentCaliperInput ?? '---'} mm',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _currentCaliperInput != null ? Colors.deepPurple : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Hidden TextField for caliper input
                          Opacity(
                            opacity: 0.0,
                            child: AbsorbPointer(
                              absorbing: false, // Always allow input
                              child: TextField(
                                controller: _caliperInputController,
                                focusNode: _caliperFocusNode,
                                keyboardType: TextInputType.number,
                                autofocus: true,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (!calibrationComplete)
                            ElevatedButton(
                              onPressed: _currentCaliperInput != null ? _nextStep : null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                textStyle: const TextStyle(fontSize: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Next Step'),
                            ),
                          if (calibrationComplete)
                            ElevatedButton(
                              onPressed: () => Navigator.of(dialogContext).pop(true), // Indicate success
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                textStyle: const TextStyle(fontSize: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.green,
                              ),
                              child: const Text('Finish Calibration'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
