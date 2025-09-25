import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:window_manager/window_manager.dart';
import 'package:flutter/foundation.dart';
// import 'dart:io';
import 'home_content.dart';
import 'config/app_theme.dart';
import 'services/app_lifecycle_service.dart';
import 'services/session_service.dart';

class BvmManualInspectionStationApp extends StatefulWidget {
  const BvmManualInspectionStationApp({super.key});

  @override
  State<BvmManualInspectionStationApp> createState() => _BvmManualInspectionStationAppState();
}

class _BvmManualInspectionStationAppState extends State<BvmManualInspectionStationApp> {
  // final FocusNode _focusNode = FocusNode();
  bool _isFullScreen = false;
  final AppLifecycleService _lifecycleService = AppLifecycleService();

  @override
  void initState() {
    super.initState();
  _lifecycleService.initialize();
  _checkExistingSession();
  }

  @override
  void dispose() {
    _lifecycleService.dispose();
    super.dispose();
  }

  // Check if user has an existing session on app start
  Future<void> _checkExistingSession() async {
    try {
      _log('_checkExistingSession: Starting session check');
      
      final session = await SessionService.getSessionStatus();
      
      if (session != null) {
        if (session.status == 'pending_calibration') {
          print('[LOG] Found incomplete session, user needs to complete calibration');
          // You could show a dialog or navigate to calibration here
        } else if (session.status == 'calibrated') {
          // Session completed, clean up
          await SessionService.clearSession();
          print('[LOG] Previous session was completed, cleared from storage');
        }
      } else {
        print('[LOG] No existing session found');
      }
    } catch (e) {
      print('[ERROR] Failed to check existing session: $e');
      print('[LOG] Continuing without session check - app should still work');
      // Continue without session - app should still work
    }
  }
  
  void _log(String message) {
    print('[App] $message');
  }

  // Fullscreen/windowed logic removed for web-only build

  // Add this method to force refresh in fullscreen
  // No-op for web-only build
  void _forceRefreshInFullscreen() {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BVM Manual Inspection Station',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: FullscreenAwareWidget(
        isFullScreen: _isFullScreen,
        onStateChanged: _forceRefreshInFullscreen,
        child: const OnboardingScreen(),
      ),
    );
  }
}

// Add the missing FullscreenAwareWidget class
class FullscreenAwareWidget extends StatefulWidget {
  final Widget child;
  final bool isFullScreen;
  final VoidCallback? onStateChanged;

  const FullscreenAwareWidget({
    super.key,
    required this.child,
    required this.isFullScreen,
    this.onStateChanged,
  });

  @override
  State<FullscreenAwareWidget> createState() => _FullscreenAwareWidgetState();
}

class _FullscreenAwareWidgetState extends State<FullscreenAwareWidget> {
  @override
  void didUpdateWidget(FullscreenAwareWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Force repaint when fullscreen status changes
    if (oldWidget.isFullScreen != widget.isFullScreen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
          widget.onStateChanged?.call();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap in RepaintBoundary to force repaints in fullscreen
    return RepaintBoundary(
      key: ValueKey(widget.isFullScreen), // Force rebuild when fullscreen changes
      child: widget.child,
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