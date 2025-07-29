import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:media_kit/media_kit.dart';
import 'app.dart';
import 'config/app_config.dart';

void main() {
  MediaKit.ensureInitialized();
  developer.log('Starting Flutter app with backend URL: ${AppConfig.backendBaseUrl}');
  runApp(BvmManualInspectionStationApp());
} 