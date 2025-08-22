import 'dart:convert';
import 'dart:async';
import 'dart:ui'; // Import for ImageFilter

import 'package:bvm_manual_inspection_station/elements/onboarding_screen/adb_device_check_button_archive.dart';
import 'package:bvm_manual_inspection_station/utils/route_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'elements/onboarding_screen/morphing_user_entry_button.dart';
import 'elements/onboarding_screen/morphing_device_connected_button.dart';
import 'elements/onboarding_screen/morphing_calibration_button.dart';
import 'config/app_theme.dart';
import 'elements/common_elements/common_appbar.dart';
import 'config/app_config.dart';
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
      final baseurl=AppConfig.backendBaseUrl;
      final response = Uri.parse('$baseurl/user_entry/should_calibrate?roll_number=$rollNumber').resolveUri(Uri());
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

  // Add your _buildSteps function here
  Widget _buildSteps(BuildContext context) {
    // Define your steps (labels or any other info you want)
    final List<String> _steps = _shouldCalibrate ? ['1', '2', '3'] : ['1', '2'];

    // Use AppTheme palette
    const Color stepActive = AppTheme.primary;
    const Color stepCompleted = AppTheme.secondary;
    const Color stepInactive = Color(0xFFE0E7EF);

    List<Widget> steps = [];

    for (int i = 0; i < _steps.length; i++) {
      steps.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemedStepCircle(
              isCompleted: _completedStep > i,
              isActive: _completedStep == i,
              label: _steps[i],
              activeColor: stepActive,
              completedColor: stepCompleted,
              inactiveColor: stepInactive,
            ),
            if (i < _steps.length - 1) ...[
              const SizedBox(width: 40),
              _ThemedStepLine(isActive: _completedStep >= i + 1, color: stepActive),
              const SizedBox(width: 40),
            ],
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: steps,
    );
  }

  Widget _buildCurrentStepAndroid(BuildContext context) {
  // Use AppTheme palette
  const Color stepActive = AppTheme.primary;
  const Color stepCompleted = AppTheme.secondary;
  const Color stepInactive = Color(0xFFE0E7EF);

  Widget stepButton;
  if (_completedStep == 0) {
    stepButton = MorphingUserEntryButton(
      enabled: true,
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
      buttonBg: stepActive,
      buttonFg: Colors.white,
      buttonBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  } else if (_completedStep == 1) {
    stepButton = MorphingDeviceConnectedButton(
      enabled: true,
      onComplete: () {
        setState(() {
          _completedStep = 2;
        });
        if (!_shouldCalibrate) {
          Future.delayed(const Duration(milliseconds: 600), () {
            Navigator.of(context).push(createSlideUpRoute());
          });
        }
      },
      buttonBg: stepActive,
      buttonFg: Colors.white,
      buttonBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  } else if (_completedStep == 2 && _shouldCalibrate) {
    stepButton = MorphingCalibrationButton(
      enabled: true,
      onComplete: () {
        setState(() {
          _completedStep = 3;
        });
        Future.delayed(const Duration(milliseconds: 600), () {
          Navigator.of(context).push(createSlideUpRoute());
        });
      },
      buttonBg: stepActive,
      buttonFg: Colors.white,
      buttonBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  } else {
    stepButton = const SizedBox.shrink();
  }

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _ThemedStepCircle(
        isCompleted: false,
        isActive: true,
        label: (_completedStep + 1).toString(),
        activeColor: stepActive,
        completedColor: stepCompleted,
        inactiveColor: stepInactive,
      ),
      const SizedBox(height: 32),
      stepButton,
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    // Use AppTheme palette
    const Color stepActive = AppTheme.primary;
    const Color stepCompleted = AppTheme.secondary;
    const Color stepInactive = Color(0xFFE0E7EF);

    Color getButtonBg(int step) {
      if (_completedStep > step) return AppTheme.secondary;
      if (_completedStep == step) return AppTheme.primary;
      // Use a lighter grey than the card container for inactive state
      return const Color(0xFF3A3D46); // Lighter grey for morphing button background
    }
    Color getButtonFg(int step) {
      if (_completedStep >= step) return Colors.white;
      // Use a medium grey for text/icons on lighter grey button background
      return const Color(0xFFB0B4BA); // Muted grey for better harmony
    }
    OutlinedBorder getButtonBorder(int step) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _completedStep >= step ? Colors.transparent : AppTheme.primary.withOpacity(0.2),
          width: 2,
        ),
      );
    }


  if (Theme.of(context).platform == TargetPlatform.android) {
    // Android: Show only the current step, centered, with same background as Windows
    return Column(
      children: [
        const BvmAppBar(),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.bgColor,
                  AppTheme.bgColor.withOpacity(0.95),
                  AppTheme.primary.withOpacity(0.05),
                ],
              ),
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Card(
                      color: AppTheme.cardBg.withOpacity(0.95),
                      elevation: 10,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(32, 56, 32, 36),
                        child: _buildCurrentStepAndroid(context),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  } else {
    return Column(
      children: [
        const BvmAppBar(),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppTheme.bgColor,
      AppTheme.bgColor.withOpacity(0.95),
      AppTheme.primary.withOpacity(0.05),
    ],
  ),
),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Card(
                      color: AppTheme.cardBg.withOpacity(0.95),
                      elevation: 10,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(32, 56, 32, 36),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Replace the old stepper Row with your new function
                            _buildSteps(context),
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
                                    ] ,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
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
    // Always use black text for step circle
    Color fgColor = Colors.black;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: activeColor.withOpacity(0.25),
              blurRadius: 16,
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
          fontSize: 26,
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
        // No borderRadius for sharp corners
      ),
    );
  }
}
