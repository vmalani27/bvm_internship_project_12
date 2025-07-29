import 'dart:convert';

import 'package:bvm_manual_inspection_station/utils/route_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'step_circle.dart';
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
    Color getButtonBg(int step) {
      if (_completedStep > step) return const Color(0xFF4CAF50); // Completed: green
      if (_completedStep == step) {
        if (step == 3 && _completedStep == 3) return const Color(0xFF4CAF50); // Step 3 completed: green
        return const Color(0xFF2196F3); // Active: blue
      }
      if (_completedStep >= 3 && step == 3) return const Color(0xFF4CAF50); // Step 3 completed: green
      return Colors.white; // Initial/inactive: white
    }
    Color getButtonFg(int step) {
      if (_completedStep > step) return Colors.white;
      if (_completedStep == step) {
        if (step == 3 && _completedStep == 3) return Colors.white;
        return Colors.white;
      }
      if (_completedStep >= 3 && step == 3) return Colors.white;
      return Colors.grey; // Initial/inactive: gray text
    }
    OutlinedBorder getButtonBorder(int step) {
      if (_completedStep < step) {
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFBDBDBD), width: 2), // Gray border
        );
      }
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      );
    }

    return Expanded(
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'BVM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 32),
              // Timeline/Progress Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Step 1 Circle
                  StepCircle(
                    isCompleted: _completedStep > 1,
                    isActive: _completedStep == 1,
                    label: '1',
                  ),
                  StepLine(isActive: _completedStep >= 2),
                  // Step 2 Circle
                  StepCircle(
                    isCompleted: _completedStep > 2,
                    isActive: _completedStep == 2,
                    label: '2',
                  ),
                  if (_shouldCalibrate) ...[
                    StepLine(isActive: _completedStep == 3),
                    // Step 3 Circle
                    StepCircle(
                      isCompleted: _completedStep > 2 && _completedStep == 3,
                      isActive: _completedStep == 3,
                      label: '3',
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Step 1
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Step 1',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
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
                        'Step 2',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
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
                            // Logging: Skipping calibration
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

                      // AdbDeviceCheckButton(
                      //   enabled: _completedStep == 1,
                      //   onComplete: () {
                      //     setState(() {
                      //       _completedStep = 2;
                      //     });
                      //   },
                      //   buttonBg: getButtonBg(2),
                      //   buttonFg: getButtonFg(2),
                        
                      // ),
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
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        MorphingCalibrationButton(
                          enabled: _completedStep == 2,
                          onComplete: () {
                            setState(() {
                              _completedStep = 3;
                            });
                            // Logging: Step 3 Calibration started
                            // ignore: avoid_print
                            print('[LOG] Step 3: Calibration started');
                            // Logging: Step 3 Calibration completed
                            // ignore: avoid_print
                            print('[LOG] Step 3: Calibration completed');
                            // After a short delay, show slide up transition to NextPage
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
      ),
    );
  }
}
