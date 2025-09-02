import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
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
  final FocusNode _focusNode = FocusNode();
  bool _isFullScreen = false;
  final AppLifecycleService _lifecycleService = AppLifecycleService();

  @override
  void initState() {
    super.initState();
    _lifecycleService.initialize();
    _checkFullscreenStatus();
    _checkExistingSession();
  }

  @override
  void dispose() {
    _lifecycleService.dispose();
    super.dispose();
  }

  // Check if user has an existing session on app start
  Future<void> _checkExistingSession() async {
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
    }
  }

  Future<void> _checkFullscreenStatus() async {
    if (kIsWeb) return;
    if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) return;
    
    _isFullScreen = await windowManager.isFullScreen();
    setState(() {});
  }

  Future<void> _exitFullscreenIfNeeded() async {
    if (kIsWeb) return;
    if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) return;
    
    final bool isFs = await windowManager.isFullScreen();
    if (isFs) {
      await windowManager.setFullScreen(false);
      await windowManager.setTitleBarStyle(TitleBarStyle.normal);
      await windowManager.setSize(const Size(1400, 900));
      await windowManager.center();
      
      setState(() {
        _isFullScreen = false;
      });
    }
  }

  // Add this method to force refresh in fullscreen
  void _forceRefreshInFullscreen() {
    if (_isFullScreen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): _exitFullscreenIfNeeded,
        // Add F11 to toggle fullscreen
        const SingleActivator(LogicalKeyboardKey.f11): () async {
          if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
            final isFs = await windowManager.isFullScreen();
            await windowManager.setFullScreen(!isFs);
            setState(() {
              _isFullScreen = !isFs;
            });
          }
        },
      },
      child: Focus(
        autofocus: true,
        focusNode: _focusNode,
        child: MaterialApp(
          title: 'BVM Manual Inspection Station',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.themeData,
          home: FullscreenAwareWidget(
            isFullScreen: _isFullScreen,
            onStateChanged: _forceRefreshInFullscreen,
            child: const OnboardingScreen(),
          ),
        ),
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