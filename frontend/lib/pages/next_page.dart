import 'dart:ui';
import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import 'measurement_category_page.dart';
import '../elements/common_appbar.dart';


class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use AppTheme palette for dark theme
    final Color bgColor = AppTheme.bgColor;
    final Color cardBg = AppTheme.cardBg;
    final Color accent = AppTheme.primary;
    final Color textColor = AppTheme.textDark;
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const BvmAppBar(),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardBg.withOpacity(0.98),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 52),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.easeInOut,
                              child: Icon(Icons.straighten, size: 90, color: accent),
                            ),
                            const SizedBox(height: 36),
                            Text(
                              'Welcome to BVM Inspection Assistant',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                letterSpacing: 1.3,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'A workstation software connected to your vernier caliper via USB,',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: textColor.withOpacity(0.85),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'automating measurement entry and easing your workflow.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: textColor.withOpacity(0.85),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 36),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minWidth: 200,
                                    maxWidth: 320,
                                  ),
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.play_circle_fill, size: 30),
                                    label: const Text('Start Video Inspection', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accent,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 8,
                                      shadowColor: accent.withOpacity(0.25),
                                      textStyle: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const MeasurementCategoryPage(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
