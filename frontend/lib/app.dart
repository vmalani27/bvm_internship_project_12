import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'home_content.dart';
import 'config/app_theme.dart';

class BvmManualInspectionStationApp extends StatefulWidget {
  const BvmManualInspectionStationApp({super.key});

  @override
  State<BvmManualInspectionStationApp> createState() => _BvmManualInspectionStationAppState();
}

class _BvmManualInspectionStationAppState extends State<BvmManualInspectionStationApp> {
  final FocusNode _focusNode = FocusNode();

  Future<void> _exitFullscreenIfNeeded() async {
    if (kIsWeb) return; // Browser handles its own fullscreen.
    if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) return; // Desktop only.
    final bool isFs = await windowManager.isFullScreen();
    if (isFs) {
      await windowManager.setFullScreen(false);
      // Optionally restore to a sane size & show title bar
      await windowManager.setTitleBarStyle(TitleBarStyle.normal);
      await windowManager.setSize(const Size(1400, 900));
      await windowManager.center();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): _exitFullscreenIfNeeded,
      },
      child: Focus(
        autofocus: true,
        focusNode: _focusNode,
        child: MaterialApp(
          title: 'BVM Manual Inspection Station',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.themeData,
          home: const OnboardingScreen(),
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor, // Use theme background color
      
      body: const HomeContent(),
    );
  }
}