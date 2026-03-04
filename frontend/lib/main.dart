import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'dart:developer' as developer;

import 'app.dart';
import 'config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  developer.log(
    'Starting Flutter web app with backend URL: ${AppConfig.backendBaseUrl}',
  );

  runApp(const BvmManualInspectionStationApp());
}
