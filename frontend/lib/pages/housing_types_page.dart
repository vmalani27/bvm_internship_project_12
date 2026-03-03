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

class _HousingTypesPageState extends State<HousingTypesPage> {
  List<String> housingTypes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHousingTypes();
  }

  Future<void> _loadHousingTypes() async {
    try {
      final types = await ApiService.getHousingTypes();
      if (mounted) {
        setState(() {
          housingTypes = types;
          isLoading = false;
        });
      }
      developer.log('Housing types loaded: $housingTypes');
    } catch (e) {
      developer.log('Error loading housing types: $e');
      if (mounted) {
        setState(() {
          housingTypes = [
            'oval',
            'square',
            'angular',
          ]; // Fixed fallback spelling
          isLoading = false;
        });
      }
    }
  }

  void _selectHousingType(String housingType) {
    developer.log('Selected housing type: $housingType');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (context) => MeasurementStepPage(
              category: housingType,
              model: MeasurementStepModel(category: housingType),
            ),
      ),
    );
  }

  IconData _getIcon(String housingType) {
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

  String _getDisplayName(String type) {
    switch (type.toLowerCase()) {
      case 'sqaure':
      case 'square':
        return 'Square Housing';
      case 'oval':
        return 'Oval Housing';
      case 'angular':
        return 'Angular Housing';
      default:
        return '${type.substring(0, 1).toUpperCase()}${type.substring(1)} Housing';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.bgColor,
              AppTheme.bgColor.withOpacity(0.95),
              AppTheme.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            const BvmAppBar(showBackButton: true),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 900),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Housing Type',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Choose the type of housing to measure.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textBody,
                                ),
                              ),
                            ],
                          ),
                        ),
                        isLoading
                            ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(48.0),
                                child: CircularProgressIndicator(
                                  color: AppTheme.primary,
                                ),
                              ),
                            )
                            : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 280,
                                    mainAxisExtent: 140, // Height of card
                                    crossAxisSpacing: 24,
                                    mainAxisSpacing: 24,
                                  ),
                              itemCount: housingTypes.length,
                              itemBuilder: (context, index) {
                                final type = housingTypes[index];
                                return _buildHousingCard(type);
                              },
                            ),
                      ],
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

  Widget _buildHousingCard(String type) {
    return Card(
      color: AppTheme.cardBg,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: InkWell(
        onTap: () => _selectHousingType(type),
        borderRadius: BorderRadius.circular(16),
        hoverColor: AppTheme.primary.withOpacity(0.05),
        highlightColor: AppTheme.primary.withOpacity(0.1),
        splashColor: AppTheme.primary.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getIcon(type), color: AppTheme.primary, size: 28),
              ),
              const Spacer(),
              Text(
                _getDisplayName(type),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
