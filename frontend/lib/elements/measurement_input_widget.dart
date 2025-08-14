import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import 'dart:developer' as developer;

class MeasurementInputWidget extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isLastStep;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onCaliperCheckPressed;
  final Color accent;
  final FocusNode caliperFocusNode;
  final bool isCaliperChecking;

  const MeasurementInputWidget({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.isLastStep,
    required this.onNext,
    required this.onBack,
    required this.onCaliperCheckPressed,
    required this.accent,
    required this.caliperFocusNode,
    required this.isCaliperChecking,
  });

  void _showStepInfoDialog(BuildContext context) {
    String infoText = '';
    if (label.contains('Height')) {
      infoText = '''To measure the height:
1. Extend the depth bar by sliding the movable jaw.
2. Place the base of the caliper on one end of the object and insert the depth bar until it touches the other end.
3. Read the measurement from the main and vernier scales.''';
    } else if (label.contains('Radius')) {
      infoText = '''To measure the radius:
1. Open the Vernier caliper.
2. Place the inside jaws inside the circular opening.
3. Gently expand the jaws until they touch the inner walls.
4. Read the measurement from the main and vernier scales.''';
    } else if (label.contains('Depth')) {
      infoText = '''To measure the depth:
1. Extend the depth rod by sliding the movable jaw.
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
  Widget build(BuildContext context) {
    final Color textColor = AppTheme.textDark;
    final Color cardBg = AppTheme.cardBg;
    
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: 80,
          ),
          decoration: BoxDecoration(
            color: cardBg.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.info_outline_rounded, color: accent),
                    tooltip: 'More info',
                    onPressed: () => _showStepInfoDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // The caliper trigger is now part of the TextFormField itself.
              TextFormField(
                key: ValueKey('input_$label'),
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(fontSize: 16, color: textColor),
                // Add an onTap callback to the TextFormField.
                onTap: () {
                  // This is the new fallback logic:
                  // Only trigger the caliper if the field is empty.
                  if (controller.text.isEmpty) {
                    developer.log('[Widget] TextFormField tapped to trigger caliper');
                    onCaliperCheckPressed();
                  }
                },
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accent.withOpacity(0.3), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accent, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  suffixIcon: IconButton(
                    icon: isCaliperChecking
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                          )
                        : Icon(Icons.straighten_rounded, color: accent),
                    // The dedicated button can still be used to re-trigger a measurement
                    onPressed: isCaliperChecking ? null : () {
                      developer.log('[Widget] Caliper button pressed');
                      onCaliperCheckPressed();
                    },
                    tooltip: 'Start caliper measurement',
                  ),
                  prefixIcon: isCaliperChecking ? IconButton(
                    icon: Icon(Icons.bug_report, color: Colors.orange),
                    onPressed: () {
                      developer.log('[Widget] Test input button pressed');
                      controller.text = '25.50';
                    },
                    tooltip: 'Test caliper input',
                  ) : null,
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
              const SizedBox(height: 24),
            ],
          ),
        ),
        // Hidden TextField for caliper input
        Positioned(
          left: -1000,
          top: -1000,
          child: SizedBox(
            height: 0.1,
            width: 0.1,
            child: TextField(
              key: const ValueKey('caliper_input_field'),
              controller: controller,
              focusNode: caliperFocusNode,
              keyboardType: TextInputType.number,
              autofocus: false,
              onChanged: (value) {
                developer.log('[Caliper] Hidden input received: $value');
              },
            ),
          ),
        ),
        // Adjust button row position
        Positioned(
          bottom: 24,
          left: 24,
          right: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  cardBg.withOpacity(0),
                  cardBg,
                  cardBg,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: onBack,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent.withOpacity(0.8),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        developer.log('[Input] Clear measurement requested');
                        controller.clear();
                      },
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          developer.log('[Input] Next pressed with value: ${controller.text}');
                          onNext();
                        } else {
                          developer.log('[Input] Next pressed but no measurement entered');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a measurement before proceeding'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLastStep ? 'Review' : 'Next',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isLastStep ? Icons.check_rounded : Icons.arrow_forward_rounded,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
