import 'package:bvm_manual_inspection_station/elements/onboarding_screen/dialogboxes/caliper_calibration_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // For Future.delayed
import 'package:bvm_manual_inspection_station/elements/common_elements/common_flushbar.dart';
import 'dart:convert';

class MorphingCalibrationButton extends StatefulWidget {
  final bool enabled;
  final VoidCallback onComplete;
  final Color buttonBg;
  final Color buttonFg;
  final OutlinedBorder buttonBorder;
  const MorphingCalibrationButton({
    required this.enabled,
    required this.onComplete,
    required this.buttonBg,
    required this.buttonFg,
    required this.buttonBorder,
    super.key,
  });

  @override
  State<MorphingCalibrationButton> createState() => _MorphingCalibrationButtonState();
}

class _MorphingCalibrationButtonState extends State<MorphingCalibrationButton> {
  bool _morphed = false;
  bool _calibrating = false; // Indicates if the calibration process (dialog) is active
  String? _calibrationError; // To store if calibration failed/cancelled

  void _startCalibration() async {
    if (!widget.enabled || _calibrating) return; // Prevent multiple clicks

    setState(() {
      _calibrating = true; // Set to true while dialog is open
      _calibrationError = null; // Clear previous errors
    });

    // Show the calibration dialog
    final bool? calibrationResult = await showDialog<bool?>(
      context: context,
      barrierDismissible: false, // User must interact with dialog buttons
      builder: (BuildContext context) {
        return const CaliperCalibrationDialog();
      },
    );

    // After the dialog is closed
    setState(() {
      _calibrating = false; // Calibration process is no longer active
      if (calibrationResult == true) {
        // Calibration completed successfully
        _morphed = true;
        // Log success
        // ignore: avoid_print
        print('[LOG] Caliper calibration completed successfully.');
      } else {
        // Calibration was cancelled or failed
        _morphed = false; // Ensure button is not in morphed state
        _calibrationError = 'Calibration cancelled or failed.'; // Set error state
        // Show "Please retry" dialog
        _showRetryCalibrationDialog();
        // Log cancellation/failure
        // ignore: avoid_print
        print('[LOG] Caliper calibration cancelled or failed.');
      }
    });

    // If calibration was successful, trigger onComplete after a short delay for animation
    if (_morphed) {
      Future.delayed(const Duration(milliseconds: 350), widget.onComplete);
    }
  }

  void _showRetryCalibrationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Calibration Required'),
          content: const Text(
              'Calibration was not completed. Please retry calibration to ensure '
              'accurate measurements.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss this dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine the current background color based on error state
    Color currentButtonBg = _calibrationError != null ? Colors.red.shade700 : widget.buttonBg;
    // Determine the current foreground color based on error state
    Color currentButtonFg = _calibrationError != null ? Colors.white : widget.buttonFg;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      width: _morphed ? 260 : 140,
      height: _morphed || _calibrationError != null ? 140 : 56,
      decoration: BoxDecoration(
        color: currentButtonBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: !_morphed ? currentButtonFg.withOpacity(0.18) : const Color(0xFFb6c1d1),
          width: 1.2,
        ),
      ),
      child: _morphed
          ? Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: currentButtonFg, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Calibrated!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: currentButtonFg,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentButtonFg,
                        foregroundColor: currentButtonBg,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // Logging: Step 3 continue pressed
                        // ignore: avoid_print
                        print('[LOG] Step 3: Continue pressed after calibration');
                        setState(() {
                          _morphed = false;
                          _calibrationError = null;
                        });
                        Future.delayed(const Duration(milliseconds: 350), widget.onComplete);
                      },
                      child: const Text('Continue'),
                    ),
                  ],
                ),
              ),
            )
          : Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: widget.enabled && !_calibrating ? _startCalibration : null,
                child: Center(
                  child: _calibrating
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: currentButtonFg),
                        )
                      : Column( // Display initial button or error message
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_calibrationError != null) ...[
                              Icon(Icons.error, color: currentButtonFg, size: 32), // Error icon in foreground color
                              const SizedBox(height: 8),
                              Text(
                                'Calibration Failed', // Generic message, dialog gives details
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: currentButtonFg,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            Text(
                              _calibrationError != null ? 'Retry Calibration' : 'Calibration',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: currentButtonFg,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
    );
  }
}
