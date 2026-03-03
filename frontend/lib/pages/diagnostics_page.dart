import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../elements/common_elements/common_appbar.dart';
import '../elements/onboarding_screen/morphing_device_connected_button.dart';
import '../elements/onboarding_screen/morphing_calibration_button.dart';

class DiagnosticsPage extends StatelessWidget {
  const DiagnosticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              const BvmAppBar(title: 'Diagnostics', showBackButton: true),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'System Diagnostics',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Verify hardware connections and calibrate measurement tools.',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textBody,
                            ),
                          ),
                          const SizedBox(height: 48),

                          _buildDiagnosticItem(
                            title: 'Hardware Connection',
                            description:
                                'Verify the caliper is successfully sending measurement data to the station.',
                            child: MorphingDeviceConnectedButton(
                              enabled: true,
                              onComplete: () {},
                              buttonBg: AppTheme.cardBg,
                              buttonFg: AppTheme.textDark,
                              buttonBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          _buildDiagnosticItem(
                            title: 'Tool Calibration',
                            description:
                                'Zero out and calibrate the digital caliper for precise measurements.',
                            child: MorphingCalibrationButton(
                              enabled: true,
                              onComplete: () {},
                              buttonBg: AppTheme.cardBg,
                              buttonFg: AppTheme.textDark,
                              buttonBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosticItem({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textBody.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
