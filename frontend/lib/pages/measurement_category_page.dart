import 'dart:ui';
import 'package:bvm_manual_inspection_station/pages/past_measurements.dart';
import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import 'measurement_step_page.dart';
import '../models/measurement_step_model.dart';
import '../elements/common_appbar.dart';

// MeasurementCategoryPage: Ask user to select Shaft or Housing for manual measurement
class MeasurementCategoryPage extends StatefulWidget {
  const MeasurementCategoryPage({super.key});

  @override
  State<MeasurementCategoryPage> createState() => _MeasurementCategoryPageState();
}

class _MeasurementCategoryPageState extends State<MeasurementCategoryPage> with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _buttonsController;
  late Animation<double> _titleAnimation;
  late Animation<double> _buttonsAnimation;

  @override
  void initState() {
    super.initState();
    
    _titleController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _buttonsController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    
    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic)
    );
    _buttonsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonsController, curve: Curves.easeOutBack)
    );
    
    _titleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () => _buttonsController.forward());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _buttonsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = AppTheme.bgColor;
    final Color cardBg = AppTheme.cardBg;
    final Color accent = AppTheme.primary;
    final Color secondary = AppTheme.secondary;
    final Color textColor = AppTheme.textDark;
    
    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              bgColor,
              bgColor.withOpacity(0.95),
              accent.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const BvmAppBar(title: 'Select Component to Measure'),
              Expanded(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                cardBg.withOpacity(0.95),
                                cardBg.withOpacity(0.98),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 25,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: accent.withOpacity(0.1),
                                blurRadius: 40,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                              // Animated title
                              AnimatedBuilder(
                                animation: _titleAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 20 * (1 - _titleAnimation.value)),
                                    child: Opacity(
                                      opacity: _titleAnimation.value,
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  accent.withOpacity(0.15),
                                                  accent.withOpacity(0.05),
                                                ],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: accent.withOpacity(0.2),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.category_rounded,
                                              size: 50,
                                              color: accent,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          Text(
                                            'Select Component',
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Choose the component you want to measure',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: textColor.withOpacity(0.7),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              
                              const SizedBox(height: 40),
                              
                              // Animated buttons
                              AnimatedBuilder(
                                animation: _buttonsAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _buttonsAnimation.value,
                                    child: Column(
                                      children: [
                                        // Housing Button
                                        Container(
                                          width: double.infinity,
                                          height: 60,
                                          margin: const EdgeInsets.only(bottom: 12),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                accent,
                                                accent.withOpacity(0.8),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: accent.withOpacity(0.3),
                                                blurRadius: 15,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(20),
                                              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MeasurementStepPage(
                      category: 'housing',
                      model: MeasurementStepModel(category: 'housing'),
                    ),
                  ),
                );
              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(10),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Icon(
                                                        Icons.straighten_rounded,
                                                        size: 20,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Housing',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.white,
                                                              letterSpacing: 0.5,
                                                            ),
                                                          ),
                                                          Text(
                                                            'Measure housing dimensions',
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.w500,
                                                              color: Colors.white.withOpacity(0.9),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons.arrow_forward_ios_rounded,
                                                      size: 18,
                                                      color: Colors.white.withOpacity(0.8),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        
                                        // Shaft Button
                                        Container(
                                          width: double.infinity,
                                          height: 60,
                                          margin: const EdgeInsets.only(bottom: 16),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                secondary,
                                                secondary.withOpacity(0.8),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: secondary.withOpacity(0.3),
                                                blurRadius: 15,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(20),
                                              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MeasurementStepPage(
                      category: 'shaft',
                      model: MeasurementStepModel(category: 'shaft'),
                    ),
                  ),
                );
              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(10),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Icon(
                                                        Icons.settings_rounded,
                                                        size: 20,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Shaft',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.white,
                                                              letterSpacing: 0.5,
                                                            ),
                                                          ),
                                                          Text(
                                                            'Measure shaft dimensions',
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.w500,
                                                              color: Colors.white.withOpacity(0.9),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons.arrow_forward_ios_rounded,
                                                      size: 18,
                                                      color: Colors.white.withOpacity(0.8),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        
                                        // Past Measurements Button
                                        Container(
                                          width: double.infinity,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(16),
                                              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PastMeasurementsPage()),
                );
              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.history_rounded,
                                                      size: 20,
                                                      color: textColor.withOpacity(0.8),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      'View Past Measurements',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                        color: textColor.withOpacity(0.8),
                                                        letterSpacing: 0.3,
              ),
            ),
          ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 