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
      size: Size(1920, 1080), // Set initial size
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden, // Hide title bar for fullscreen feel
    );
    
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setFullScreen(true); // Set to fullscreen
    });
    
    developer.log('Desktop platform - fullscreen mode enabled');
  } else {
    // Mobile platforms (Android/iOS) - use SystemChrome
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    developer.log('Mobile platform - immersive mode enabled');
  }
  
  developer.log('Starting Flutter app with backend URL: ${AppConfig.backendBaseUrl}');
  runApp(BvmManualInspectionStationApp());
} 