import 'package:bvm_manual_inspection_station/pages/past_measurements.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_theme.dart';
import 'measurement_step_page.dart';
import 'housing_types_page.dart';
import 'diagnostics_page.dart';
import '../models/measurement_step_model.dart';
import '../elements/common_elements/common_appbar.dart';

// DashboardPage (Replaces MeasurementCategoryPage): Main action hub
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKey(KeyEvent event, BuildContext context) {
    if (event is! KeyDownEvent) return;
    final char = event.character;
    if (char == '1') _goHousing(context);
    if (char == '2') _goShaft(context);
    if (char == '3') _goHistory(context);
    if (char == '4') _goDiagnostics(context);
  }

  void _goHousing(BuildContext context) => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const HousingTypesPage()));

  void _goShaft(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute(
      builder:
          (_) => MeasurementStepPage(
            category: 'shaft',
            model: MeasurementStepModel(category: 'shaft'),
          ),
    ),
  );

  void _goHistory(BuildContext context) => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const PastMeasurementsPage()));

  void _goDiagnostics(BuildContext context) => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const DiagnosticsPage()));

  @override
  Widget build(BuildContext context) {
    final Color bgColor = AppTheme.bgColor;
    final Color cardBg = AppTheme.cardBg;
    final Color primary = AppTheme.primary;
    final Color secondary = AppTheme.secondary;
    final Color textColor = AppTheme.textDark;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) => _handleKey(event, context),
      child: Scaffold(
        backgroundColor: bgColor,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                bgColor,
                bgColor.withOpacity(0.95),
                primary.withOpacity(0.05),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const BvmAppBar(title: 'Dashboard'),
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 32,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Inspection Tasks',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Select an action to continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textColor.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tip: Press 1–4 to jump directly to any section',
                              style: TextStyle(
                                fontSize: 13,
                                color: textColor.withOpacity(0.4),
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Action Cards Grid
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final double cardWidth =
                                    constraints.maxWidth > 500
                                        ? (constraints.maxWidth - 24) / 2
                                        : constraints.maxWidth;
                                return Wrap(
                                  spacing: 24,
                                  runSpacing: 24,
                                  children: [
                                    SizedBox(
                                      width: cardWidth,
                                      child: _buildActionCard(
                                        context: context,
                                        title: 'Housing Measurement',
                                        subtitle: 'Measure housing dimensions',
                                        shortcut: '1',
                                        icon: Icons.straighten_rounded,
                                        color: primary,
                                        cardBg: cardBg,
                                        onTap: () => _goHousing(context),
                                      ),
                                    ),
                                    SizedBox(
                                      width: cardWidth,
                                      child: _buildActionCard(
                                        context: context,
                                        title: 'Shaft Measurement',
                                        subtitle: 'Measure shaft dimensions',
                                        shortcut: '2',
                                        icon: Icons.settings_rounded,
                                        color: secondary,
                                        cardBg: cardBg,
                                        onTap: () => _goShaft(context),
                                      ),
                                    ),
                                    SizedBox(
                                      width: cardWidth,
                                      child: _buildActionCard(
                                        context: context,
                                        title: 'Past Measurements',
                                        subtitle:
                                            'View historical inspection data',
                                        shortcut: '3',
                                        icon: Icons.history_rounded,
                                        color: Colors.blueGrey,
                                        cardBg: cardBg,
                                        onTap: () => _goHistory(context),
                                      ),
                                    ),
                                    SizedBox(
                                      width: cardWidth,
                                      child: _buildActionCard(
                                        context: context,
                                        title: 'System Diagnostics',
                                        subtitle:
                                            'Verify hardware and calibration',
                                        shortcut: '4',
                                        icon: Icons.build_circle_rounded,
                                        color: AppTheme.accent,
                                        cardBg: cardBg,
                                        onTap: () => _goDiagnostics(context),
                                      ),
                                    ),
                                  ],
                                );
                              },
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
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String shortcut,
    required IconData icon,
    required Color color,
    required Color cardBg,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          hoverColor: color.withOpacity(0.05),
          highlightColor: color.withOpacity(0.1),
          splashColor: color.withOpacity(0.15),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, size: 36, color: color),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textDark.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Keyboard shortcut badge
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: color.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        shortcut,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
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
