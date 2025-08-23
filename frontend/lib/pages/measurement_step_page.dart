import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import '../models/measurement_step_model.dart';
import '../config/media_kit_video_player.dart';
import '../config/app_theme.dart';
import 'measurement_summary_widget.dart';
import '../elements/measurement_input_widget.dart';
import '../models/measurement_step_controller.dart'; // <-- NEW CONTROLLER

class MeasurementStepPage extends StatefulWidget {
  final String category;
  final MeasurementStepModel model;

  const MeasurementStepPage({
    super.key,
    required this.category,
    required this.model,
  });

  @override
  State<MeasurementStepPage> createState() => _MeasurementStepPageState();
}

class _MeasurementStepPageState extends State<MeasurementStepPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productIdController = TextEditingController();
  
  late MeasurementStepController controller;

  late AnimationController _titleController;
  late AnimationController _contentController;
  late Animation<double> _titleAnimation;
  late Animation<double> _contentAnimation;

  bool _productIdSet = false;

  @override
  void initState() {
    super.initState();
    controller = MeasurementStepController(model: widget.model);
    _setupAnimations();
    developer.log('[Init] MeasurementStepPage initialized for ${widget.category}');
    developer.log('[Init] Is housing category: $_isHousingCategory');
    controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _setupAnimations() {
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic),
    );
    _contentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutBack),
    );

    _titleController.forward();
    Future.delayed(
      const Duration(milliseconds: 300),
      () => _contentController.forward(),
    );
  }



  @override
  void dispose() {
    _productIdController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    controller.dispose();
    super.dispose();
  }

    Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: MeasurementSummaryWidget(model: widget.model),
      ),
    );
  }

  Widget _buildStepIndicator(Color cardBg, Color accent, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.straighten_rounded,
              size: 20,
              color: accent,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Step ${widget.model.currentStep + 1} of ${widget.model.steps.length}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    try {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: MediaKitVideoPlayer(
            player: widget.model.player,
            videoController: widget.model.videoController,
            isLoading: widget.model.isVideoLoading,
          ),
        ),
      );
    } catch (e, stackTrace) {
      developer.log('Error creating MediaKitVideoPlayer: $e');
      developer.log('Stack trace: $stackTrace');
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('Error loading video player'),
              const SizedBox(height: 8),
              Text('$e', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      );
    }
  }


  bool get _isHousingCategory {
    return widget.category != 'shaft'; // All non-shaft categories are housing types
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = AppTheme.bgColor;
    final Color cardBg = AppTheme.cardBg;
    final Color accent = _isHousingCategory
        ? AppTheme.primary
        : AppTheme.secondary;
    final Color textColor = AppTheme.textDark;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Main content first (background)
          Container(
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
                  // Custom AppBar
                  _buildAppBar(cardBg, accent, textColor),
                  Expanded(
                    child: AbsorbPointer(
                      // Absorb pointer events when caliper is checking
                      absorbing: controller.isCaliperChecking,
                      child: ListenableBuilder(
                        listenable: Listenable.merge([widget.model, controller]),
                        builder: (context, _) {
                          if (!_productIdSet) {
                            return _buildProductIdCard(cardBg, accent, textColor);
                          }

                          if (widget.model.isSummary) {
                            return _buildSummaryCard();
                          }

                          final currentStep = widget.model.steps[widget.model.currentStep];
                          developer.log('[Step] Current step: ${widget.model.currentStep}');

                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(24.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildStepIndicator(cardBg, accent, textColor),
                                  const SizedBox(height: 24),
                                  _buildVideoPlayer(),
                                  const SizedBox(height: 24),
                                  // Update MeasurementInputWidget integration
                                  MeasurementInputWidget(
                                    label: currentStep['label'],
                                    hint: currentStep['hint'],
                                    controller: controller.measurementController,
                                    isLastStep: widget.model.currentStep == widget.model.steps.length - 1,
                                    onNext: () {
                                      developer.log('[Input] Next pressed');
                                      if (controller.measurementController.text.isNotEmpty) {
                                        controller.goNextStep();
                                      }
                                    },
                                    onBack: () {
                                      developer.log('[Input] Back pressed');
                                      controller.goBackStep();
                                    },
                                    accent: accent,
                                    onCaliperCheckPressed: () async {
                                      developer.log('[Input] Caliper check requested');
                                      // Use the controller's built-in caliper handling instead of dialog
                                      controller.initiateCaliperCheck(context);
                                    },
                                    isCaliperChecking: controller.isCaliperChecking,
                                    caliperFocusNode: controller.caliperFocusNode,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    
          // Add hidden TextField for caliper input
          if (controller.isCaliperChecking)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (_) => FocusScope.of(context).requestFocus(controller.caliperFocusNode),
                child: Container(
                  color: Colors.transparent,
                  child: TextField(
                    controller: controller.measurementController,
                    focusNode: controller.caliperFocusNode,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    style: const TextStyle(
                      color: Colors.transparent,
                      fontSize: 1,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      developer.log('[TextField] Direct input received: "$value"');
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar(Color cardBg, Color accent, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: cardBg.withOpacity(0.95),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios_rounded, color: textColor),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_isHousingCategory ? 'Housing' : 'Shaft'} Measurement',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Step-by-step measurement process',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Add reset button before the category icon
          IconButton(
            onPressed: () {
              developer.log('[Redo] Starting new measurement for same part');
              setState(() {
                controller.reset();
                _productIdSet = false;
                _productIdController.clear();
              });
            },
            icon: Icon(Icons.restart_alt_rounded, color: textColor),  // Changed icon
            tooltip: 'Restart Measurement',  // Added tooltip
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _isHousingCategory
                  ? Icons.straighten_rounded
                  : Icons.settings_rounded,
              size: 20,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductIdCard(Color cardBg, Color accent, Color textColor) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
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
                            Icons.qr_code_2_rounded,
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
                        offset:
                            Offset(0, 20 * (1 - _titleAnimation.value)),
                        child: Opacity(
                          opacity: _titleAnimation.value,
                          child: Column(
                            children: [
                              Text(
                                _isHousingCategory 
                                  ? 'Enter Housing ID'
                                  : 'Enter Product ID',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isHousingCategory
                                  ? 'Please enter the housing ID to continue with measurement'
                                  : 'Please enter the product ID to continue with measurement',
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
                  const SizedBox(height: 32),
                  AnimatedBuilder(
                    animation: _contentAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _contentAnimation.value,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _productIdController,
                              style: TextStyle(
                                  fontSize: 18, color: textColor),
                              decoration: InputDecoration(
                                labelText: _isHousingCategory 
                                  ? 'Housing ID'
                                  : 'Product ID',
                                labelStyle: TextStyle(
                                    color: accent,
                                    fontWeight: FontWeight.w600),
                                prefixIcon: Icon(
                                    Icons.confirmation_number_rounded,
                                    color: accent),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                      color: accent.withOpacity(0.3),
                                      width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide:
                                      BorderSide(color: accent, width: 2),
                                ),
                                filled: true,
                                fillColor:
                                    Colors.white.withOpacity(0.05),
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 20),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
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
                                    if (_productIdController.text
                                        .trim()
                                        .isNotEmpty) {
                                      developer.log('[ProductID] Product ID set: ${_productIdController.text.trim()}');
                                      developer.log('[ProductID] Category: ${widget.category}, Is housing: $_isHousingCategory');
                                      setState(() {
                                        widget.model.productId =
                                            _productIdController.text.trim();
                                        _productIdSet = true;
                                      });
                                    }
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.arrow_forward_rounded,
                                          size: 24, color: Colors.white),
                                      SizedBox(width: 12),
                                      Text(
                                        'Continue',
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
      ));
    }
  }
