import 'dart:convert';

import 'package:bvm_manual_inspection_station/utils/route_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'step_circle.dart';
import 'elements/onboarding_screen/morphing_user_entry_button.dart';
import 'elements/onboarding_screen/morphing_device_connected_button.dart';
import 'elements/onboarding_screen/morphing_calibration_button.dart';
import 'main.dart' show createSlideUpRoute;
import 'elements/onboarding_screen/adb_device_check_button_archive.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  int _completedStep = 0;
  bool _shouldCalibrate = true; // New state to track calibration flag

  @override
  void initState() {
    super.initState();
    _fetchCalibrationFlag();
  }

  Future<void> _fetchCalibrationFlag() async {
    // TODO: Replace with actual user roll_number retrieval logic
    const String rollNumber = "test_roll_number";

    try {
      final response = await Uri.parse('http://127.0.0.1:8000/user_entry/should_calibrate?roll_number=$rollNumber').resolveUri(Uri());
      final httpResponse = await http.get(response);
      if (httpResponse.statusCode == 200) {
        final data = jsonDecode(httpResponse.body);
        setState(() {
          _shouldCalibrate = data['should_calibrate'] ?? true;
        });
      } else {
        // On error, default to showing calibration button
        setState(() {
          _shouldCalibrate = true;
        });
      }
    } catch (e) {
      // On exception, default to showing calibration button
      setState(() {
        _shouldCalibrate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simple color palette
    const Color blue = Color(0xFF4F8CFF);
    const Color teal = Color(0xFF2DD4BF);
    const Color cardBg = Color(0xFFFFFFFF);
    const Color stepActive = blue;
    const Color stepCompleted = teal;
    const Color stepInactive = Color(0xFFE0E7EF);

    Color getButtonBg(int step) {
      if (_completedStep > step) return stepCompleted;
      if (_completedStep == step) return stepActive;
      return cardBg;
    }
    Color getButtonFg(int step) {
      if (_completedStep >= step) return Colors.white;
      return blue.withOpacity(0.7);
    }
    OutlinedBorder getButtonBorder(int step) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _completedStep >= step ? Colors.transparent : blue.withOpacity(0.2),
          width: 2,
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF7FAFC), // Simple, clean background
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Branding
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bubble_chart_rounded, color: teal, size: 40),
                    const SizedBox(width: 12),
                    const Text(
                      'BVM',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Glassmorphic Card
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(color: blue.withOpacity(0.08), width: 1.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Stepper
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Step 1 Circle
                          _ThemedStepCircle(
                            isCompleted: _completedStep > 1,
                            isActive: _completedStep == 1,
                            label: '1',
                            activeColor: stepActive,
                            completedColor: stepCompleted,
                            inactiveColor: stepInactive,
                          ),
                          _ThemedStepLine(isActive: _completedStep >= 2, color: stepActive),
                          // Step 2 Circle
                          _ThemedStepCircle(
                            isCompleted: _completedStep > 2,
                            isActive: _completedStep == 2,
                            label: '2',
                            activeColor: stepActive,
                            completedColor: stepCompleted,
                            inactiveColor: stepInactive,
                          ),
                          if (_shouldCalibrate) ...[
                            _ThemedStepLine(isActive: _completedStep == 3, color: stepActive),
                            _ThemedStepCircle(
                              isCompleted: _completedStep > 2 && _completedStep == 3,
                              isActive: _completedStep == 3,
                              label: '3',
                              activeColor: stepActive,
                              completedColor: stepCompleted,
                              inactiveColor: stepInactive,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Steps
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Step 1
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'User Entry',
                                style: TextStyle(color: Colors.black54, fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              MorphingUserEntryButton(
                                enabled: _completedStep == 0,
                                onComplete: () {
                                  setState(() {
                                    _completedStep = 1;
                                  });
                                },
                                onShouldCalibrateChanged: (bool value) {
                                  setState(() {
                                    _shouldCalibrate = value;
                                  });
                                },
                                buttonBg: getButtonBg(1),
                                buttonFg: getButtonFg(1),
                                buttonBorder: getButtonBorder(1),
                              ),
                            ],
                          ),
                          const SizedBox(width: 32),
                          // Step 2
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Device Connect',
                                style: TextStyle(color: Colors.black54, fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              MorphingDeviceConnectedButton(
                                enabled: _completedStep == 1,
                                onComplete: () {
                                  setState(() {
                                    _completedStep = 2;
                                  });
                                  if (!_shouldCalibrate) {
                                    // Skip calibration and move to next page
                                    print('[LOG] Skipping calibration, moving to next page');
                                    Future.delayed(const Duration(milliseconds: 600), () {
                                      Navigator.of(context).push(createSlideUpRoute());
                                    });
                                  }
                                },
                                buttonBg: getButtonBg(2),
                                buttonFg: getButtonFg(2),
                                buttonBorder: getButtonBorder(2),
                              ),
                            ],
                          ),
                          const SizedBox(width: 32),
                          // Step 3
                          if (_shouldCalibrate)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Calibration',
                                  style: TextStyle(color: Colors.black54, fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                MorphingCalibrationButton(
                                  enabled: _completedStep == 2,
                                  onComplete: () {
                                    setState(() {
                                      _completedStep = 3;
                                    });
                                    print('[LOG] Step 3: Calibration started');
                                    print('[LOG] Step 3: Calibration completed');
                                    Future.delayed(const Duration(milliseconds: 600), () {
                                      Navigator.of(context).push(createSlideUpRoute());
                                    });
                                  },
                                  buttonBg: getButtonBg(3),
                                  buttonFg: getButtonFg(3),
                                  buttonBorder: getButtonBorder(3),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
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

// Themed step circle for Gemini/ChatGPT look
class _ThemedStepCircle extends StatelessWidget {
  final bool isCompleted;
  final bool isActive;
  final String label;
  final Color activeColor;
  final Color completedColor;
  final Color inactiveColor;
  const _ThemedStepCircle({
    required this.isCompleted,
    required this.isActive,
    required this.label,
    required this.activeColor,
    required this.completedColor,
    required this.inactiveColor,
  });
  @override
  Widget build(BuildContext context) {
    Color bgColor = isCompleted
        ? completedColor
        : isActive
            ? activeColor
            : inactiveColor;
    Color fgColor = isCompleted || isActive ? Colors.white : Colors.black38;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: activeColor.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: fgColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}

// Themed step line for Gemini/ChatGPT look
class _ThemedStepLine extends StatelessWidget {
  final bool isActive;
  final Color color;
  const _ThemedStepLine({required this.isActive, required this.color});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      width: 36,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isActive ? color : color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
