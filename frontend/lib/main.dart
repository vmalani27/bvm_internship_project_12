import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:media_kit/media_kit.dart';
import 'app.dart';
import 'config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  
  // Configure fullscreen based on platform
  if (kIsWeb) {
    // Web platform - use CSS fullscreen (handled in web/index.html)
    developer.log('Web platform detected - fullscreen handled by browser');
  } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    // Desktop platforms - use window_manager
    await windowManager.ensureInitialized();
    
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1920, 1080), // Initial size before fullscreen
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden, // Hide title bar for fullscreen feel
    );
    
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      
      // Set true fullscreen for perfect screen fit
      await windowManager.setFullScreen(true);
      
      // Additional step: ensure it covers the entire screen
      await windowManager.setAlwaysOnTop(false);
    });
    
    developer.log('Desktop platform - true fullscreen enabled for perfect screen fit');
  } else {
    // Mobile platforms (Android/iOS) - use SystemChrome
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    developer.log('Mobile platform - immersive mode enabled');
  }
  
  developer.log('Starting Flutter app with backend URL: ${AppConfig.backendBaseUrl}');
  developer.log('Diagnostics: isProduction=${AppConfig.isProduction} platform=${kIsWeb ? 'web' : (Platform.isAndroid ? 'android' : Platform.isWindows ? 'windows' : Platform.isLinux ? 'linux' : Platform.isMacOS ? 'macos' : 'other')}');
  try {
    // Quick TCP reachability hint (desktop only, skip on web/mobile if restrictions apply)
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      final sw = Stopwatch()..start();
      final socket = await Socket.connect(Uri.parse(AppConfig.backendBaseUrl).host, Uri.parse(AppConfig.backendBaseUrl).port, timeout: const Duration(milliseconds: 600));
      sw.stop();
      developer.log('Backend reachability: TCP connect succeeded in ${sw.elapsedMilliseconds}ms');
      socket.destroy();
    }
  } catch (e) {
    developer.log('Backend reachability: FAILED -> $e');
  }
  runApp(BvmManualInspectionStationApp());
} 