import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../services/api_service.dart';
import 'measurement_step_page.dart';
import '../models/measurement_step_model.dart';
import '../elements/common_elements/common_appbar.dart';
import 'dart:developer' as developer;

class HousingTypesPage extends StatefulWidget {
  const HousingTypesPage({super.key});

  @override
  State<HousingTypesPage> createState() => _HousingTypesPageState();
}

class _HousingTypesPageState extends State<HousingTypesPage> with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _buttonsController;
  late Animation<double> _titleAnimation;
  late Animation<double> _buttonsAnimation;
  
  List<String> housingTypes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadHousingTypes();
  }

  void _setupAnimations() {
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

  Future<void> _loadHousingTypes() async {
    try {
      final types = await ApiService.getHousingTypes();
      setState(() {
        housingTypes = types;
        isLoading = false;
      });
      developer.log('Housing types loaded: $housingTypes');
    } catch (e) {
      developer.log('Error loading housing types: $e');
      setState(() {
        housingTypes = ['oval', 'sqaure', 'angular']; // Fallback
        isLoading = false;
      });
    }
  }

  void _selectHousingType(String housingType) {
    developer.log('Selected housing type: $housingType');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MeasurementStepPage(
          category: housingType, // Use the specific housing type
          model: MeasurementStepModel(category: housingType),
        ),
      ),
    );
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
        child: Column(
          children: [
            const BvmAppBar(),
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _titleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _titleAnimation.value,
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
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
                                      Icons.home_work_rounded,
                                      size: 60,
                                      color: accent,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 32),
                            AnimatedBuilder(
                              animation: _titleAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, 20 * (1 - _titleAnimation.value)),
                                  child: Opacity(
                                    opacity: _titleAnimation.value,
                                    child: Column(
                                      children: [
                                        Text(
                                          'Select Housing Type',
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Choose the type of housing to measure',
                                          textAlign: TextAlign.center,
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
                            const SizedBox(height: 48),
                            if (isLoading)
                              CircularProgressIndicator(color: accent)
                            else
                              AnimatedBuilder(
                                animation: _buttonsAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _buttonsAnimation.value,
                                    child: Column(
                                      children: housingTypes.map((type) => 
                                        _buildHousingTypeButton(type, accent, textColor)
                                      ).toList(),
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
    );
  }

  Widget _buildHousingTypeButton(String type, Color accent, Color textColor) {
    IconData getIcon(String housingType) {
      switch (housingType.toLowerCase()) {
        case 'oval':
          return Icons.circle_outlined;
        case 'sqaure':
        case 'square':
          return Icons.crop_square_rounded;
        case 'angular':
          return Icons.change_history_rounded;
        default:
          return Icons.home_work_rounded;
      }
    }

    String getDisplayName(String type) {
      switch (type.toLowerCase()) {
        case 'sqaure':
          return 'Square Housing';
        case 'oval':
          return 'Oval Housing';
        case 'angular':
          return 'Angular Housing';
        default:
          return '${type.substring(0, 1).toUpperCase()}${type.substring(1)} Housing';
      }
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton.icon(
        onPressed: () => _selectHousingType(type),
        icon: Icon(getIcon(type), size: 28),
        label: Text(
          getDisplayName(type),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: accent.withOpacity(0.3),
        ),
      ),
    );
  }
}
