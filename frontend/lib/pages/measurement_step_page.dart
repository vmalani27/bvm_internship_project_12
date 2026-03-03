import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import '../models/measurement_step_model.dart';
import '../elements/common_elements/common_appbar.dart';
import '../config/media_kit_video_player.dart';
import '../config/app_theme.dart';
import 'measurement_summary_widget.dart';
import '../elements/measurement_input_widget.dart';
import '../models/measurement_step_controller.dart'; // <-- NEW CONTROLLER
import '../services/api_service.dart';

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

class _MeasurementStepPageState extends State<MeasurementStepPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productIdController = TextEditingController();

  late MeasurementStepController controller;
  bool _productIdSet = false;

  @override
  void initState() {
    super.initState();
    controller = MeasurementStepController(model: widget.model);
    developer.log(
      '[Init] MeasurementStepPage initialized for ${widget.category}',
    );
    developer.log('[Init] Is housing category: $_isHousingCategory');
    controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _productIdController.dispose();
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.straighten_rounded, size: 16, color: accent),
            const SizedBox(width: 8),
            Text(
              'Step ${widget.model.currentStep + 1} of ${widget.model.steps.length}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
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
              Icon(Icons.error, color: AppTheme.error, size: 48),
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
    return widget.category !=
        'shaft'; // All non-shaft categories are housing types
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = AppTheme.bgColor;
    final Color cardBg = AppTheme.cardBg;
    final Color accent =
        _isHousingCategory ? AppTheme.primary : AppTheme.secondary;
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
                  BvmAppBar(
                    title:
                        '${_isHousingCategory ? 'Housing' : 'Shaft'} Measurement',
                    showBackButton: true,
                  ),
                  Expanded(
                    child: AbsorbPointer(
                      // Absorb pointer events when caliper is checking
                      absorbing: controller.isCaliperChecking,
                      child: ListenableBuilder(
                        listenable: Listenable.merge([
                          widget.model,
                          controller,
                        ]),
                        builder: (context, _) {
                          if (!_productIdSet) {
                            return _buildProductIdCard(
                              cardBg,
                              accent,
                              textColor,
                            );
                          }

                          if (widget.model.isSummary) {
                            return _buildSummaryCard();
                          }

                          final currentStep =
                              widget.model.steps[widget.model.currentStep];
                          developer.log(
                            '[Step] Current step: ${widget.model.currentStep}',
                          );

                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(24.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildStepIndicator(
                                    cardBg,
                                    accent,
                                    textColor,
                                  ),
                                  const SizedBox(height: 24),
                                  _buildVideoPlayer(),
                                  const SizedBox(height: 24),
                                  // Update MeasurementInputWidget integration
                                  MeasurementInputWidget(
                                    label: currentStep['label'],
                                    hint: currentStep['hint'],
                                    controller:
                                        controller.measurementController,
                                    isLastStep:
                                        widget.model.currentStep ==
                                        widget.model.steps.length - 1,
                                    onNext: () {
                                      developer.log('[Input] Next pressed');
                                      if (controller
                                          .measurementController
                                          .text
                                          .isNotEmpty) {
                                        controller.goNextStep();
                                      }
                                    },
                                    onBack: () {
                                      developer.log('[Input] Back pressed');
                                      controller.goBackStep();
                                    },
                                    accent: accent,
                                    onCaliperCheckPressed: () async {
                                      developer.log(
                                        '[Input] Caliper check requested',
                                      );
                                      // Use the controller's built-in caliper handling instead of dialog
                                      controller.initiateCaliperCheck(context);
                                    },
                                    onCaliperStopPressed: () {
                                      developer.log(
                                        '[Input] Caliper stop requested',
                                      );
                                      controller.stopCaliperCheck();
                                    },
                                    isCaliperChecking:
                                        controller.isCaliperChecking,
                                    caliperFocusNode:
                                        controller.caliperFocusNode,
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
                onTapDown:
                    (_) => FocusScope.of(
                      context,
                    ).requestFocus(controller.caliperFocusNode),
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
                      developer.log(
                        '[TextField] Direct input received: "$value"',
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductIdCard(Color cardBg, Color accent, Color textColor) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Card(
          color: cardBg,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.qr_code_scanner_rounded, size: 48, color: accent),
                const SizedBox(height: 24),
                Text(
                  _isHousingCategory ? 'Enter Housing ID' : 'Enter Product ID',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isHousingCategory
                      ? 'Please enter the housing ID to begin.'
                      : 'Please enter the product ID to begin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: AppTheme.textBody),
                ),
                const SizedBox(height: 32),
                StatefulBuilder(
                  builder: (context, setInner) {
                    String? statusText;
                    Color statusColor = Colors.transparent;
                    bool checking = false;

                    Future<void> doCheck() async {
                      final enteredProductId = _productIdController.text.trim();
                      if (enteredProductId.isEmpty) return;
                      setInner(() {
                        checking = true;
                      });
                      final exists = await ApiService.productExists(
                        productId: enteredProductId,
                        measurementType:
                            _isHousingCategory ? 'housing' : 'shaft',
                      );
                      setInner(() {
                        checking = false;
                        statusText =
                            exists ? 'ID already used' : 'ID available';
                        statusColor =
                            exists ? AppTheme.error : AppTheme.success;
                      });
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _productIdController,
                          onChanged: (_) {
                            setInner(() {
                              statusText = null;
                            });
                          },
                          onFieldSubmitted: (_) => doCheck(),
                          style: TextStyle(fontSize: 16, color: textColor),
                          decoration: InputDecoration(
                            labelText:
                                _isHousingCategory
                                    ? 'Housing ID'
                                    : 'Product ID',
                            suffixIcon:
                                checking
                                    ? Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: accent,
                                        ),
                                      ),
                                    )
                                    : null,
                            labelStyle: TextStyle(color: AppTheme.textBody),
                            prefixIcon: Icon(
                              Icons.tag_rounded,
                              color: AppTheme.textBody,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: accent, width: 2),
                            ),
                            filled: true,
                            fillColor: AppTheme.bgColor,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                          ),
                        ),
                        if (statusText != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            statusText!,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () async {
                            final entered = _productIdController.text.trim();
                            if (entered.isEmpty) return;
                            final exists = await ApiService.productExists(
                              productId: entered,
                              measurementType:
                                  _isHousingCategory ? 'housing' : 'shaft',
                            );
                            if (exists) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'ID already exists. Choose a different one.',
                                  ),
                                  backgroundColor: AppTheme.error,
                                ),
                              );
                              return;
                            }
                            developer.log(
                              '[ProductID] Product ID set: $entered',
                            );
                            setState(() {
                              widget.model.productId = entered;
                              _productIdSet = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
