import 'dart:ui';

import 'package:flutter/material.dart';
import 'elements/onboarding_screen/morphing_user_entry_button.dart';
import 'config/app_theme.dart';
import 'elements/common_elements/common_appbar.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _userEntryCompleted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const BvmAppBar(showLogoutButton: false),
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
                constraints: const BoxConstraints(maxWidth: 900),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Card(
                      color: AppTheme.cardBg.withOpacity(0.95),
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Welcome to Workspace",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Sign in to begin your inspection session.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppTheme.textBody,
                                ),
                              ),
                              const SizedBox(height: 32),

                              Center(
                                child:
                                    _userEntryCompleted
                                        ? ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.primary,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 48,
                                              vertical: 20,
                                            ),
                                            textStyle: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            elevation: 4,
                                          ),
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/dashboard',
                                            );
                                          },
                                          child: const Text('Start Inspection'),
                                        )
                                        : MorphingUserEntryButton(
                                          enabled: true,
                                          onComplete: () {
                                            setState(() {
                                              _userEntryCompleted = true;
                                            });
                                          },
                                          onShouldCalibrateChanged:
                                              (bool value) {},
                                          buttonBg: AppTheme.primary,
                                          buttonFg: Colors.white,
                                          buttonBorder: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
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
            ),
          ),
        ),
      ],
    );
  }
}
