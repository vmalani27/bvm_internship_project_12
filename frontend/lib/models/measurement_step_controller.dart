import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../models/measurement_step_model.dart';
import 'package:flutter/foundation.dart';

class MeasurementStepController extends ChangeNotifier {
  final MeasurementStepModel model;
  final TextEditingController measurementController = TextEditingController();
  final FocusNode caliperFocusNode = FocusNode();
  Timer? _checkTimeoutTimer;
  Timer? _inputCompletionTimer;
  
  // Make the field public instead of private
  bool isCaliperChecking = false;
  String? caliperError;

  MeasurementStepController({required this.model}) {
    developer.log('[Controller] Initializing controller');
    _setupCaliperInput();
    _setupFocusListener();
    model.addListener(_handleStepChange);
    // Add immediate logging of initial state
    developer.log('[Controller] Initial step: ${model.currentStep}');
    developer.log('[Controller] Initial field: ${model.currentField}');
  }

  void _setupFocusListener() {
    caliperFocusNode.addListener(() {
      developer.log('[Caliper] Focus changed - hasFocus: ${caliperFocusNode.hasFocus}');
    });
  }

  void _setupCaliperInput() {
    developer.log('[Controller] Setting up caliper input listener');
    measurementController.addListener(() {
      developer.log('[Caliper] Input listener triggered - isCaliperChecking: $isCaliperChecking');
      
      if (!isCaliperChecking) {
        developer.log('[Caliper] Ignored: Not in checking state');
        return;
      }

      String currentText = measurementController.text;
      developer.log('[Caliper] Raw input: "$currentText" (Length: ${currentText.length})');

      // Cancel previous timer
      _inputCompletionTimer?.cancel();
      
      // Set a timer to process the input after a brief pause
      _inputCompletionTimer = Timer(const Duration(milliseconds: 150), () {
        if (isCaliperChecking) {
          developer.log('[Caliper] Processing input after delay');
          _processCaliperMeasurement(currentText);
        }
      });
    });
  }

  void _handleStepChange() {
    developer.log('[Controller] Step changed to: ${model.currentStep}');
    final field = model.currentField;
    isCaliperChecking = false;  // Reset checking state on step change
    measurementController.text = model.measurements[field] ?? '';
    notifyListeners();
  }

  void initiateCaliperCheck(BuildContext context) {
    developer.log('[Caliper] Starting check for step ${model.currentStep}');
    
    isCaliperChecking = true;
    caliperError = null;
    measurementController.clear();
    
    // Request focus with a delay to ensure the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(caliperFocusNode);
      developer.log('[Caliper] Focus requested for caliper input');
    });
    
    // Set timeout
    _checkTimeoutTimer?.cancel();
    _checkTimeoutTimer = Timer(const Duration(seconds: 10), () {
      if (isCaliperChecking) {
        developer.log('[Caliper] Timeout reached, no input detected');
        _handleCaliperTimeout(context);
      }
    });

    notifyListeners();
  }

  void _processCaliperMeasurement(String measurementText) {
    if (!isCaliperChecking) {
      developer.log('[Caliper] Processing cancelled - not in checking state');
      return; // Prevent processing when not checking
    }
    
    developer.log('[Caliper] Processing measurement: "$measurementText"');
    _checkTimeoutTimer?.cancel();
    String dimension = measurementText.trim();
    
    // Clear the input controller and request focus for next input
    measurementController.clear();
    caliperFocusNode.requestFocus();
    
    if (dimension.isNotEmpty && double.tryParse(dimension) != null) {
      developer.log('[Caliper] Valid measurement: $dimension');
      model.measurements[model.currentField] = dimension;
      isCaliperChecking = false;  // Update state
      caliperFocusNode.unfocus();

      if (model.currentStep >= model.steps.length - 1) {
        model.showSummary();
      } else {
        model.nextStep(dimension);
      }
      notifyListeners();
    } else {
      developer.log('[Caliper] Invalid measurement or empty input: "$dimension"');
      // Don't clear the controller here as it's already cleared above
      // Keep focus for retry
      caliperFocusNode.requestFocus();
    }
  }

  void _handleCaliperTimeout(BuildContext context) {
    isCaliperChecking = false;  // Update state
    caliperFocusNode.unfocus();
    notifyListeners();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Caliper Not Detected'),
        content: const Text('Please ensure your caliper is connected and try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void goNextStep() {
    developer.log('[Controller] Going to next step');
    final currentValue = measurementController.text.trim();
    
    if (currentValue.isNotEmpty) {
      model.measurements[model.currentField] = currentValue;
    }

    if (model.currentStep >= model.steps.length - 1) {
      model.showSummary();
    } else {
      model.nextStep(currentValue);
      measurementController.clear();
    }
    notifyListeners();
  }

  void goBackStep() {
    developer.log('[Controller] Going to previous step');
    model.prevStep();
    final field = model.currentField;
    if (field.isNotEmpty && model.measurements.containsKey(field)) {
      measurementController.text = model.measurements[field] ?? '';
    }
    notifyListeners();
  }

  void reset() {
    developer.log('[Controller] Resetting state');
    measurementController.clear();
    isCaliperChecking = false;
    caliperError = null;
    model.reset();  // This should reset the model's state
    notifyListeners();
  }

  
  void clearCurrentMeasurement() {
    developer.log('[Controller] Clearing current measurement');
    measurementController.clear();
    if (model.currentField.isNotEmpty) {
      model.measurements.remove(model.currentField);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _checkTimeoutTimer?.cancel();
    _inputCompletionTimer?.cancel();
    measurementController.dispose();
    caliperFocusNode.dispose();
    model.removeListener(_handleStepChange);
    super.dispose();
  }
}
