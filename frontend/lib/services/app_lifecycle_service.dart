import 'package:flutter/material.dart';
import '../services/session_service.dart';

class AppLifecycleService extends WidgetsBindingObserver {
  static final AppLifecycleService _instance = AppLifecycleService._internal();
  factory AppLifecycleService() => _instance;
  AppLifecycleService._internal();

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.detached:
        _handleAppClosed();
        break;
      default:
        break;
    }
  }

  void _handleAppPaused() {
    // App is paused - could save state here
    print('App paused - user session may be incomplete');
  }

  void _handleAppResumed() async {
    // Check for incomplete sessions when app resumes
    final session = await SessionService.getSessionStatus();
    if (session != null && session.status == 'pending_calibration') {
      // Could show notification or redirect to calibration
      print('Incomplete session found on resume');
    }
  }

  void _handleAppClosed() {
    // App is closing - incomplete sessions will auto-expire on backend
    print('App closing - incomplete sessions will expire');
  }
}
