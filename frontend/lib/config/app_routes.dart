import 'package:bvm_manual_inspection_station/app.dart';
import 'package:flutter/material.dart';
import '../pages/welcome_page.dart';
import '../pages/measurement_category_page.dart';
import '../pages/measurement_summary_widget.dart';
import '../pages/past_measurements.dart';
import '../pages/video_player_page.dart';
import '../pages/submission_result_page.dart';
import '../home_content.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/welcome': (context) => const WelcomePage(),
  '/measurement_category': (context) => const MeasurementCategoryPage(),
  '/measurement_summary': (context) => const MeasurementSummaryWidget(model: null,),
  '/past_measurements': (context) => const PastMeasurementsPage(),
  '/video_player': (context) => const VideoPlayerPage(),
  '/submission_result': (context) => const SubmissionResultPage(),
  '/onboarding': (context) => const BvmManualInspectionStationApp(),
};
