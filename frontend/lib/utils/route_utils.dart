import 'package:flutter/material.dart';
import '../pages/welcome_page.dart';

// Custom slide up route for NextPage
Route createSlideUpRoute() {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (context, animation, secondaryAnimation) => const WelcomePage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final begin = const Offset(0.0, 1.0);
      final end = Offset.zero;
      final curve = Curves.easeInOut;
      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
} 