import 'package:flutter/material.dart';
import 'dart:async'; // For Future.delayed and Timer
import 'package:bvm_manual_inspection_station/elements/custom_flushbar.dart';
import 'dart:convert';

class MorphingDeviceConnectedButton extends StatefulWidget {
  final bool enabled;
  final VoidCallback onComplete;
  final Color buttonBg;
  final Color buttonFg;
  final OutlinedBorder buttonBorder; // Added this property
  const MorphingDeviceConnectedButton({
    required this.enabled,
    required this.onComplete,
    required this.buttonBg,
    required this.buttonFg,
    required this.buttonBorder, // Required in constructor
    super.key,
  });

  @override
  State<MorphingDeviceConnectedButton> createState() => _MorphingDeviceConnectedButtonState();
}

class _MorphingDeviceConnectedButtonState extends State<MorphingDeviceConnectedButton> {
  bool _morphed = false; // Controls the button's morphed state (connected/not connected)
  bool _checking = false; // Indicates if the connection check is in progress
  String? _error; // Stores internal error state: null (no error), 'timeout' (failed check)

  // TextEditingController and FocusNode for the hidden TextField
  // This TextField will capture the caliper's keyboard input.
  final TextEditingController _caliperInputController = TextEditingController();
  final FocusNode _caliperFocusNode = FocusNode();
  
  Timer? _checkTimeoutTimer; // Timer for overall connection check timeout
  Timer? _inputCompletionTimer; // Timer to detect pause in caliper input

  @override
  void initState() {
    super.initState();
    // Add a listener to the controller to detect caliper input
    _caliperInputController.addListener(_handleCaliperInput);
  }

  @override
  void dispose() {
    // Clean up resources
    _caliperInputController.removeListener(_handleCaliperInput);
    _caliperInputController.dispose();
    _caliperFocusNode.dispose();
    _checkTimeoutTimer?.cancel(); // Cancel any active overall timer
    _inputCompletionTimer?.cancel(); // Cancel any active input completion timer
    super.dispose();
  }

  /// Handles input from the hidden TextField, triggered by the caliper.
  void _handleCaliperInput() {
    // Only process if we are currently in a checking state
    if (!_checking) return;

    String currentText = _caliperInputController.text;

    // --- CRITICAL DEBUGGING LINE ---
    // This will show the exact content of the controller at each change
    // ignore: avoid_print
    print('Raw input in controller: "$currentText" (Length: ${currentText.length})');
    // -------------------------------

    // Reset the input completion timer every time a character is received.
    // If no new character comes within the duration, the timer will fire,
    // indicating the input is complete.
    _inputCompletionTimer?.cancel(); // Cancel previous timer
    _inputCompletionTimer = Timer(const Duration(milliseconds: 100), () {
      // This code runs if no new character is received for 100ms
      _processCaliperMeasurement(currentText);
    });
  }

  /// Processes the complete measurement received from the caliper.
  void _processCaliperMeasurement(String measurementText) {
    // Clear the overall connection check timeout as we've received input
    _checkTimeoutTimer?.cancel();

    // Trim any leading/trailing whitespace (though for numbers, usually none)
    String dimension = measurementText.trim();

    // Validate if the received input is a plausible number
    if (double.tryParse(dimension) != null) {
      // Caliper input successfully detected and validated
      setState(() {
        _morphed = true; // Morph to the "connected" state
        _checking = false; // Stop checking
        _error = null; // Clear any previous errors
      });
      // Unfocus the hidden TextField
      _caliperFocusNode.unfocus();
      // Clear the input controller immediately for the next measurement
      _caliperInputController.clear();
      // Log the successful detection
      // ignore: avoid_print
      print('[LOG] Caliper input detected and processed: $dimension');
    } else {
      // Input received but not a valid number (e.g., accidental key press or partial input)
      // Clear the input and continue waiting for valid input
      _caliperInputController.clear();
      // Log the invalid input
      // ignore: avoid_print
      print('[LOG] Invalid input received, clearing: "$dimension"');
      // If we are in the initial connection check, and we get invalid input,
      // we might want to show an error or continue waiting. For now, we continue waiting.
    }
  }

  /// Initiates the caliper connection check.
  Future<void> _initiateCaliperCheck() async {
    // Logging: Step 2 device check started
    // ignore: avoid_print
    print('[LOG] Step 2: Initiating caliper input check...');
    setState(() {
      _checking = true;
      _morphed = false; // Reset morphed state
      _error = null; // Clear previous errors (crucial for initial state)
    });

    // Clear any existing text in case of previous attempts
    _caliperInputController.clear();
    _inputCompletionTimer?.cancel(); // Ensure no old input completion timer is active

    // Request focus for the hidden TextField after the current frame is built
    // This ensures the TextField is ready to receive input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_caliperFocusNode);
      // Show a temporary message to the user
      showCustomFlushBar(context, 'Please press the data button on your caliper now.');
    });

    // Reintroduced the timeout timer to set the error state
    _checkTimeoutTimer = Timer(const Duration(seconds: 10), () {
      if (_checking && !_morphed) { // If still checking and not yet morphed
        setState(() {
          _checking = false;
          _error = 'timeout'; // Set internal error state to trigger red button
        });
        // Unfocus the hidden TextField
        _caliperFocusNode.unfocus();
        // Log the timeout
        // ignore: avoid_print
        print('[LOG] Caliper connection check timed out. Showing dialog.');
        
        // Show the error in an AlertDialog
        showDialog(
          context: context,
          barrierDismissible: false, // User must tap OK to dismiss
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Caliper Not Detected'),
              content: const Text(
                  'The caliper was not detected. Please ensure it\'s connected, powered on, and try pressing '
                  'its data button again.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Dismiss the dialog
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine the current background color based on error state
    Color currentButtonBg = _error != null ? Colors.red.shade700 : widget.buttonBg;
    // Determine the current foreground color based on error state
    Color currentButtonFg = _error != null ? Colors.white : widget.buttonFg;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      width: _morphed ? 260 : 140,
      height: _morphed ? 140 : 56,
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
      child: Stack( // Use Stack to overlay the hidden TextField
        children: [
          // Hidden TextField to capture caliper input
          // It's placed here so it's part of the widget tree and can receive focus/input
          Positioned.fill(
            child: Opacity(
              opacity: 0.0, // Make it completely invisible
              child: AbsorbPointer( // Prevent user from manually typing into it
                absorbing: !_checking, // Only absorb if not checking (so listener can work when checking)
                child: TextField(
                  controller: _caliperInputController,
                  focusNode: _caliperFocusNode,
                  keyboardType: TextInputType.number, // Hint for numerical input
                  autofocus: false, // Don't autofocus initially
                  // No decoration needed as it's hidden
                ),
              ),
            ),
          ),
          // Main content of the button
          Center(
            child: SingleChildScrollView( // Allows content to scroll if it overflows
              child: _morphed
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: currentButtonFg, size: 32), // Use currentButtonFg
                        const SizedBox(height: 8),
                        Text(
                          'Caliper Connected!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: currentButtonFg, // Use currentButtonFg
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currentButtonFg, // Use currentButtonFg
                            foregroundColor: currentButtonBg, // Use currentButtonBg
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            // Logging: Step 2 continue pressed
                            // ignore: avoid_print
                            print('[LOG] Step 2: Continue pressed after device connected');
                            setState(() {
                              _morphed = false; // Reset for potential future checks or re-entry
                              _error = null; // Clear error on continue
                            });
                            Future.delayed(const Duration(milliseconds: 350), widget.onComplete);
                          },
                          child: const Text('Continue'),
                        ),
                      ],
                    )
                  : _checking
                      ? SizedBox( // Changed to SizedBox to apply color to CircularProgressIndicator
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: currentButtonFg), // Use currentButtonFg
                        )
                      : Material( // Reverted to original Material/InkWell for consistency
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: widget.enabled && !_checking ? _initiateCaliperCheck : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14), // Add padding for tap area
                              child: Text(
                                _error != null ? 'Retry Check' : 'Check Device', // Corrected text logic
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: currentButtonFg, // Use currentButtonFg
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
