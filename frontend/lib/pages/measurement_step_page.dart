import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/measurement_step_model.dart';
import '../config/media_kit_video_player.dart';
import '../config/app_theme.dart';
import 'submission_result_page.dart';
import 'dart:developer' as developer;

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

class _MeasurementStepPageState extends State<MeasurementStepPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _inputController = TextEditingController();
  
  late AnimationController _titleController;
  late AnimationController _contentController;
  late Animation<double> _titleAnimation;
  late Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();
    
    _titleController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _contentController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    
    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic)
    );
    _contentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutBack)
    );
    
    _titleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () => _contentController.forward());
    
    developer.log('MeasurementStepPage initialized for category: ${widget.category}');
    developer.log('Initial step: ${widget.model.currentStep}');
    developer.log('Video controller status: ${widget.model.videoController != null ? "initialized" : "null"}');
    developer.log('Video loading status: ${widget.model.isVideoLoading}');
  }

  @override
  void dispose() {
    developer.log('MeasurementStepPage disposing');
    _inputController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  TextEditingController _productIdController = TextEditingController();
  bool _productIdSet = false;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = AppTheme.bgColor;
    final Color cardBg = AppTheme.cardBg;
    final Color accent = widget.category == 'housing' ? AppTheme.primary : AppTheme.secondary;
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
              // Custom AppBar
              Container(
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
                            '${widget.category == 'housing' ? 'Housing' : 'Shaft'} Measurement',
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.category == 'housing' ? Icons.straighten_rounded : Icons.settings_rounded,
                        size: 20,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: ListenableBuilder(
                  listenable: widget.model,
                  builder: (context, _) {
                    if (!_productIdSet) {
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
                                    // Animated icon
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
                                                Text(
                                                  'Enter Product ID',
                                                  style: TextStyle(
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.bold,
                                                    color: textColor,
                                                    letterSpacing: 1.2,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Please enter the product ID to continue with measurement',
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
                                    
                                    // Animated form
                                    AnimatedBuilder(
                                      animation: _contentAnimation,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: _contentAnimation.value,
                                          child: Column(
                                            children: [
                                              TextFormField(
                                                controller: _productIdController,
                                                style: TextStyle(fontSize: 18, color: textColor),
                                                decoration: InputDecoration(
                                                  labelText: 'Product ID',
                                                  labelStyle: TextStyle(color: accent, fontWeight: FontWeight.w600),
                                                  prefixIcon: Icon(Icons.confirmation_number_rounded, color: accent),
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(16),
                                                    borderSide: BorderSide(color: accent.withOpacity(0.3), width: 1.5),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(16),
                                                    borderSide: BorderSide(color: accent, width: 2),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white.withOpacity(0.05),
                                                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                                                      if (_productIdController.text.trim().isNotEmpty) {
                                                        setState(() {
                                                          widget.model.productId = _productIdController.text.trim();
                                                          _productIdSet = true;
                                                        });
                                                      }
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 24),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(
                                                            Icons.arrow_forward_rounded,
                                                            size: 24,
                                                            color: Colors.white,
                                                          ),
                                                          const SizedBox(width: 12),
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
                      );
                    }
                    
                    if (widget.model.isSummary) {
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: MeasurementSummaryWidget(model: widget.model),
                      );
                    }

                    final currentStep = widget.model.steps[widget.model.currentStep];
                    
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Step indicator
                            Container(
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
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Video player
                            Builder(
                              builder: (context) {
                                developer.log('Building MediaKitVideoPlayer widget');
                                developer.log('Player: ${widget.model.player}');
                                developer.log('VideoController: ${widget.model.videoController}');
                                developer.log('Is loading: ${widget.model.isVideoLoading}');
                                
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
                                          Icon(Icons.error, color: Colors.red, size: 48),
                                          SizedBox(height: 16),
                                          Text('Error loading video player'),
                                          SizedBox(height: 8),
                                          Text('$e', style: TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Measurement input
                            MeasurementInputWidget(
                              label: currentStep['label'],
                              hint: currentStep['hint'],
                              controller: _inputController,
                              isLastStep: widget.model.currentStep == widget.model.steps.length - 1,
                              onNext: _onNext,
                              onBack: _onBack,
                              accent: accent,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNext() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.model.nextStep(_inputController.text);
      _inputController.clear();
    }
  }

  void _onBack() {
    widget.model.prevStep();
    // Load the previous measurement if available
    final field = widget.model.currentField;
    if (field.isNotEmpty && widget.model.measurements.containsKey(field)) {
      _inputController.text = widget.model.measurements[field] ?? '';
    }
  }
}

class MeasurementInputWidget extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isLastStep;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Color accent;

  const MeasurementInputWidget({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.isLastStep,
    required this.onNext,
    required this.onBack,
    required this.accent,
  }) : super(key: key);

  @override
  State<MeasurementInputWidget> createState() => _MeasurementInputWidgetState();
}

class _MeasurementInputWidgetState extends State<MeasurementInputWidget> {
  final TextEditingController _caliperInputController = TextEditingController();
  final FocusNode _caliperFocusNode = FocusNode();
  bool _checking = false;
  Timer? _checkTimer;
  String _lastInput = '';

    @override
  void initState() {
    super.initState();
    _startCaliperDetection();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _caliperInputController.dispose();
    _caliperFocusNode.dispose();
    super.dispose();
  }

  void _startCaliperDetection() {
    _checkTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_checking && _caliperInputController.text != _lastInput) {
        _checking = true;
        _lastInput = _caliperInputController.text;
        
        if (_lastInput.isNotEmpty) {
          // Simulate caliper input detection
          final caliperValue = _lastInput.trim();
          if (caliperValue.isNotEmpty) {
            widget.controller.text = caliperValue;
            _caliperInputController.clear();
            _lastInput = '';
            
            // Auto-advance after a short delay
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                widget.onNext();
              }
            });
          }
        }
        _checking = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = AppTheme.textDark;
    final Color cardBg = AppTheme.cardBg;
    
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.info_outline_rounded, color: widget.accent),
                    tooltip: 'More info',
                    onPressed: () => _showStepInfoDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                key: ValueKey('input_${widget.label}'),
                controller: widget.controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(fontSize: 16, color: textColor),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: widget.accent.withOpacity(0.3), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: widget.accent, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a value';
                  }
                  final numValue = num.tryParse(value.trim());
                  if (numValue == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!widget.isLastStep)
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: widget.onBack,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_back_rounded, size: 20, color: textColor.withOpacity(0.8)),
                                const SizedBox(width: 8),
                                Text(
                                  'Back',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: textColor.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.accent,
                          widget.accent.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: widget.accent.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: widget.onNext,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.isLastStep ? 'Review' : 'Next',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                widget.isLastStep ? Icons.check_rounded : Icons.arrow_forward_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Hidden TextField to capture caliper input
        Positioned.fill(
          child: Opacity(
            opacity: 0.0,
            child: AbsorbPointer(
              absorbing: !_checking,
              child: TextField(
                controller: _caliperInputController,
                focusNode: _caliperFocusNode,
                keyboardType: TextInputType.number,
                autofocus: true,
                onChanged: (value) {
                  // This will be handled by the timer
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showStepInfoDialog(BuildContext context) {
    String infoText = '';
    if (widget.label == 'Shaft Height' || widget.label == 'Housing Height') {
      infoText = '''To measure the height:

1. Extend the depth bar (the thin rod at the end of the Vernier caliper) by sliding the movable jaw.
2. Place the base of the caliper on one end of the object and insert the depth bar until it touches the other end.
3. Read the measurement from the main and vernier scales.''';
    } else if (widget.label == 'Shaft Radius' || widget.label == 'Housing Radius') {
      infoText = '''To measure the radius:

1. Open the Vernier caliper.
2. Place the inside jaws inside the circular opening of the shaft/housing.
3. Gently expand the jaws until they touch the inner walls.
4. Read the measurement from the main and vernier scales.''';
    } else if (widget.label == 'Housing Depth') {
      infoText = '''To measure the depth:

1. Extend the depth rod (the thin rod at the end of the Vernier caliper) by sliding the movable jaw.
2. Insert the depth rod into the hole or cavity until the base of the caliper rests flat on the surface.
3. Read the measurement from the main and vernier scales.''';
    } else {
      infoText = 'Follow the instructions for this measurement.';
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Measurement Info'),
        content: Text(infoText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class MeasurementSummaryWidget extends StatelessWidget {
  final MeasurementStepModel model;

  const MeasurementSummaryWidget({
    Key? key,
    required this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color textColor = AppTheme.textDark;
    final Color accent = AppTheme.primary;
    final Color cardBg = AppTheme.cardBg;
    
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cardBg.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.withOpacity(0.2),
                  Colors.green.withOpacity(0.1),
                ],
              ),
            ),
            child: Icon(Icons.check_circle_rounded, size: 48, color: Colors.green),
          ),
          const SizedBox(height: 20),
          Text(
            'Review Your Measurements',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),
          ...model.steps.map((step) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  step['label'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
                Text(
                  model.measurements[step['field']] ?? '-',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green,
                  Colors.green.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
                         child: Material(
               color: Colors.transparent,
               child: InkWell(
                 borderRadius: BorderRadius.circular(16),
                 onTap: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Center(child: CircularProgressIndicator()),
                  );
                  final success = await model.submitMeasurements();
                  Navigator.of(context).pop(); // Remove loading dialog
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => SubmissionResultPage(success: success),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.send_rounded,
                        size: 24,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Submit Measurements',
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
        ],
      ),
    );
  }
}
