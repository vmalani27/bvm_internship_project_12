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
    Key? key,
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
  }) : super(key: key);

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
          padding: const EdgeInsets.all(24),
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
              TextFormField(
                key: ValueKey('input_${label}'),
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(fontSize: 16, color: textColor),
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
                    onPressed: isCaliperChecking ? null : onCaliperCheckPressed,
                    tooltip: 'Start caliper measurement',
                  ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!isLastStep)
                    Expanded(
                      child: Container(
                        height: 48,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: onBack,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_back_rounded, size: 20, color: textColor.withOpacity(0.8)),
                                  const SizedBox(width: 8),
                                  Text('Back',
                                      style: TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.w600, color: textColor.withOpacity(0.8))),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    flex: isLastStep ? 1 : 2,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accent,
                            accent.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: onNext,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // This is the hidden TextField that will receive caliper input
        Positioned.fill(
          child: Opacity(
            opacity: 0.0,
            child: AbsorbPointer(
              absorbing: !isCaliperChecking, // Absorb input unless checking is active
              child: TextField(
                controller: controller, // Use the same controller as the visible one
                focusNode: caliperFocusNode,
                keyboardType: TextInputType.number,
                autofocus: false, // Don't autofocus
              ),
            ),
          ),
        ),
      ],
    );
  }
}
