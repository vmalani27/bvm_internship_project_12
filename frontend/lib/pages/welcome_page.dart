import 'dart:ui';
import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import 'measurement_category_page.dart';
import '../elements/common_elements/common_appbar.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _textController;
  late AnimationController _buttonController;
  late Animation<double> _iconAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _iconController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _textController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _buttonController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    
    // Create animations
    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut)
    );
    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic)
    );
    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOutBack)
    );
    
    // Start animations with delays
    _iconController.forward();
    Future.delayed(const Duration(milliseconds: 300), () => _textController.forward());
    Future.delayed(const Duration(milliseconds: 600), () => _buttonController.forward());
  }

  @override
  void dispose() {
    _iconController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = AppTheme.bgColor;
    final Color cardBg = AppTheme.cardBg;
    final Color accent = AppTheme.primary;
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
              const BvmAppBar(),
              Expanded(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1000),
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
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Use horizontal layout for wider screens, vertical for narrow screens
                              bool isWide = constraints.maxWidth > 700;
                              
                              if (isWide) {
                                // Horizontal layout
                                return Padding(
                                  padding: const EdgeInsets.all(48),
                                  child: Row(
                                    children: [
                                      // Left side - Icon and title
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            // Animated icon
                                            AnimatedBuilder(
                                              animation: _iconAnimation,
                                              builder: (context, child) {
                                                return Transform.scale(
                                                  scale: _iconAnimation.value,
                                                  child: Container(
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
                                                      Icons.precision_manufacturing_rounded,
                                                      size: 60,
                                                      color: accent,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 24),
                                            // Title
                                            AnimatedBuilder(
                                              animation: _textAnimation,
                                              builder: (context, child) {
                                                return Transform.translate(
                                                  offset: Offset(0, 15 * (1 - _textAnimation.value)),
                                                  child: Opacity(
                                                    opacity: _textAnimation.value,
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          'Welcome to',
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.w500,
                                                            color: textColor.withOpacity(0.7),
                                                            letterSpacing: 1.5,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          'BVM Inspection',
                                                          style: TextStyle(
                                                            fontSize: 28,
                                                            fontWeight: FontWeight.bold,
                                                            color: textColor,
                                                            letterSpacing: 1.2,
                                                            height: 1.1,
                                                          ),
                                                        ),
                                                        Text(
                                                          'Assistant',
                                                          style: TextStyle(
                                                            fontSize: 28,
                                                            fontWeight: FontWeight.bold,
                                                            color: accent,
                                                            letterSpacing: 1.2,
                                                            height: 1.1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Vertical divider
                                      Container(
                                        width: 1,
                                        margin: const EdgeInsets.symmetric(horizontal: 32),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.white.withOpacity(0.3),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                      
                                      // Right side - Description and button
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Description
                                            AnimatedBuilder(
                                              animation: _textAnimation,
                                              builder: (context, child) {
                                                return Transform.translate(
                                                  offset: Offset(0, 15 * (1 - _textAnimation.value)),
                                                  child: Opacity(
                                                    opacity: _textAnimation.value,
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Professional Workstation',
                                                          style: TextStyle(
                                                            fontSize: 22,
                                                            fontWeight: FontWeight.bold,
                                                            color: textColor,
                                                            height: 1.2,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 12),
                                                        Text(
                                                          'Connected to your vernier caliper via USB for automated measurement entry and streamlined workflow.',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w500,
                                                            color: textColor.withOpacity(0.8),
                                                            height: 1.4,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            
                                            const SizedBox(height: 32),
                                            
                                            // Button
                                            AnimatedBuilder(
                                              animation: _buttonAnimation,
                                              builder: (context, child) {
                                                return Transform.scale(
                                                  scale: _buttonAnimation.value,
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 56,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin: Alignment.topLeft,
                                                        end: Alignment.bottomRight,
                                                        colors: [
                                                          accent,
                                                          accent.withOpacity(0.8),
                                                        ],
                                                      ),
                                                      borderRadius: BorderRadius.circular(16),
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
                                                        borderRadius: BorderRadius.circular(16),
                                                        onTap: () {
                                                          Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                              builder: (context) => const MeasurementCategoryPage(),
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 24),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Icon(
                                                                Icons.play_circle_fill_rounded,
                                                                size: 24,
                                                                color: Colors.white,
                                                              ),
                                                              const SizedBox(width: 12),
                                                              Text(
                                                                'Start Video Inspection',
                                                                style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.w700,
                                                                  color: Colors.white,
                                                                  letterSpacing: 0.5,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                // Vertical layout for narrow screens
                                return Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Animated icon
                                      AnimatedBuilder(
                                        animation: _iconAnimation,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: _iconAnimation.value,
                                            child: Container(
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
                                                Icons.precision_manufacturing_rounded,
                                                size: 50,
                                                color: accent,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      
                                      const SizedBox(height: 24),
                                      
                                      // Title
                                      AnimatedBuilder(
                                        animation: _textAnimation,
                                        builder: (context, child) {
                                          return Transform.translate(
                                            offset: Offset(0, 15 * (1 - _textAnimation.value)),
                                            child: Opacity(
                                              opacity: _textAnimation.value,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'Welcome to',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w500,
                                                      color: textColor.withOpacity(0.7),
                                                      letterSpacing: 1.5,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'BVM Inspection',
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.bold,
                                                      color: textColor,
                                                      letterSpacing: 1.2,
                                                      height: 1.1,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Assistant',
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.bold,
                                                      color: accent,
                                                      letterSpacing: 1.2,
                                                      height: 1.1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      
                                      const SizedBox(height: 20),
                                      
                                      // Description
                                      AnimatedBuilder(
                                        animation: _textAnimation,
                                        builder: (context, child) {
                                          return Transform.translate(
                                            offset: Offset(0, 15 * (1 - _textAnimation.value)),
                                            child: Opacity(
                                              opacity: _textAnimation.value,
                                              child: Text(
                                                'Professional workstation software connected to your vernier caliper via USB for automated measurement entry.',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: textColor.withOpacity(0.8),
                                                  height: 1.4,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      
                                      const SizedBox(height: 24),
                                      
                                      // Button
                                      AnimatedBuilder(
                                        animation: _buttonAnimation,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: _buttonAnimation.value,
                                            child: Container(
                                              width: double.infinity,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    accent,
                                                    accent.withOpacity(0.8),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(14),
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
                                                  borderRadius: BorderRadius.circular(14),
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) => const MeasurementCategoryPage(),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(
                                                          Icons.play_circle_fill_rounded,
                                                          size: 22,
                                                          color: Colors.white,
                                                        ),
                                                        const SizedBox(width: 10),
                                                        Text(
                                                          'Start Video Inspection',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w700,
                                                            color: Colors.white,
                                                            letterSpacing: 0.5,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
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
