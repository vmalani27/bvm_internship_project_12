import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer' as developer;

class CaliperMeasurementDialog extends StatefulWidget {
  final String stepLabel;
  const CaliperMeasurementDialog({super.key, required this.stepLabel});

  @override
  State<CaliperMeasurementDialog> createState() => _CaliperMeasurementDialogState();
}

class _CaliperMeasurementDialogState extends State<CaliperMeasurementDialog> {
  final TextEditingController _caliperInputController = TextEditingController();
  final FocusNode _caliperFocusNode = FocusNode();
  bool _checking = false;
  String? _error;
  Timer? _checkTimeoutTimer;
  Timer? _inputCompletionTimer;

  @override
  void initState() {
    super.initState();
    _caliperInputController.addListener(_handleCaliperInput);
    // Request focus for the hidden TextField when the dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_caliperFocusNode);
    });
    _startCaliperCheck();
  }

  void _startCaliperCheck() {
    developer.log('[Dialog] Starting caliper check');
    setState(() {
      _checking = true;
      _error = null;
    });
    
    _caliperInputController.clear();
    FocusScope.of(context).requestFocus(_caliperFocusNode);

    _checkTimeoutTimer = Timer(const Duration(seconds: 10), () {
      if (_checking) {
        developer.log('[Dialog] Timeout reached');
        setState(() {
          _checking = false;
          _error = 'timeout';
        });
        Navigator.of(context).pop(null);
      }
    });
  }

  void _handleCaliperInput() {
    if (!_checking) return;
    
    String currentText = _caliperInputController.text;
    developer.log('[Dialog] Raw input: "$currentText" (Length: ${currentText.length})');
    
    // Reset the input completion timer every time a character is received
    _inputCompletionTimer?.cancel();
    _inputCompletionTimer = Timer(const Duration(milliseconds: 100), () {
      _processCaliperMeasurement(currentText);
    });
  }

  void _processCaliperMeasurement(String measurementText) {
    if (!_checking) return;
    
    _checkTimeoutTimer?.cancel();
    String dimension = measurementText.trim();
    
    // Clear the input controller and request focus for next input
    _caliperInputController.clear();
    _caliperFocusNode.requestFocus();
    
    if (dimension.isNotEmpty && double.tryParse(dimension) != null) {
      developer.log('[Dialog] Valid measurement: $dimension');
      setState(() {
        _checking = false;
        _error = null;
      });
      _caliperFocusNode.unfocus();
      Navigator.of(context).pop(dimension);
    } else {
      developer.log('[Dialog] Invalid measurement or empty input');
      // Don't clear the controller here as it's already cleared above
    }
  }

  @override
  void dispose() {
    _caliperInputController.removeListener(_handleCaliperInput);
    _caliperInputController.dispose();
    _caliperFocusNode.dispose();
    _checkTimeoutTimer?.cancel();
    _inputCompletionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Measuring ${widget.stepLabel}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please press the data button on your caliper',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          // Hidden TextField for caliper input - using the same approach as calibration dialog
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
        ],
      ),
    );
  }
}