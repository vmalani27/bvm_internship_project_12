import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/foundation.dart';
// import 'package:window_manager/window_manager.dart';
import 'dart:developer' as developer;
// import 'dart:io';
import 'package:media_kit/media_kit.dart';
import 'app.dart';
import 'config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  
  // Configure fullscreen based on platform
  // Web platform - use CSS fullscreen (handled in web/index.html)
  developer.log('Web platform detected - fullscreen handled by browser');
  
  developer.log('Starting Flutter app with backend URL: ${AppConfig.backendBaseUrl}');
  developer.log('Diagnostics: isProduction=${AppConfig.isProduction} platform=web');
  runApp(BvmManualInspectionStationApp());
} 