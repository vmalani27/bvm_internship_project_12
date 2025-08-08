import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/measurement_step_model.dart';
import '../config/media_kit_video_player.dart';
import '../config/app_theme.dart';
import 'submission_result_page.dart';
import 'dart:developer' as developer;
import '../elements/measurement_input_widget.dart';

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
  final _productIdController = TextEditingController();
  final FocusNode _caliperFocusNode = FocusNode();

  late AnimationController _titleController;
  late AnimationController _contentController;
  late Animation<double> _titleAnimation;
  late Animation<double> _contentAnimation;

  bool _productIdSet = false;
  bool _isCaliperChecking = false;
  String? _caliperError;
  Timer? _checkTimeoutTimer;
  Timer? _inputCompletionTimer;

  @override
  void initState() {
    super.initState();
    
    _titleController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _contentController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _inputController.addListener(_handleCaliperInput);
    
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
    _inputController.removeListener(_handleCaliperInput);
    _caliperFocusNode.dispose();
    _checkTimeoutTimer?.cancel();
    _inputCompletionTimer?.cancel();
    super.dispose();
  }
  
  /// Handles input from the controller, triggered by the caliper.
  void _handleCaliperInput() {
    developer.log('Controller received input. Current text: "${_inputController.text}"');
    if (!_isCaliperChecking) return;
    
    String currentText = _inputController.text;
    
    // Debounce the input to wait for the complete value
    _inputCompletionTimer?.cancel();
    _inputCompletionTimer = Timer(const Duration(milliseconds: 150), () {
      developer.log('Input debounce complete. Processing caliper measurement.');
      _processCaliperMeasurement(currentText);
    });
  }

  /// Processes the complete measurement received from the caliper.
  void _processCaliperMeasurement(String measurementText) {
    _checkTimeoutTimer?.cancel();
    String dimension = measurementText.trim();
    developer.log('Processing raw caliper value: "$dimension"');
    
    if (double.tryParse(dimension) != null) {
      developer.log('Caliper input detected and validated. Value: $dimension');
      setState(() {
        _isCaliperChecking = false;
        _caliperError = null;
      });
      _caliperFocusNode.unfocus();
      _onNext(); // Auto-advance the step
    } else {
      developer.log('Invalid caliper input received. Clearing controller.');
      _inputController.clear();
      setState(() {
        _isCaliperChecking = false;
        _caliperError = 'invalid';
      });
    }
  }

  /// Starts the caliper connection check and focuses the hidden field.
  void _initiateCaliperCheck() {
    developer.log('Starting caliper check for "${widget.model.currentField}".');
    setState(() {
      _isCaliperChecking = true;
      _caliperError = null; // Clear any previous errors
    });
    _inputController.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please press the data button on your caliper now.'),
        duration: Duration(seconds: 10),
      ),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_caliperFocusNode);
      developer.log('Hidden TextField for caliper input now has focus.');
    });

    _checkTimeoutTimer = Timer(const Duration(seconds: 10), () {
      if (_isCaliperChecking) {
        setState(() {
          _isCaliperChecking = false;
          _caliperError = 'timeout';
        });
        _caliperFocusNode.unfocus();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Caliper Not Detected'),
            content: const Text('The caliper was not detected. Please ensure it is connected and try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  void _onNext() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.model.nextStep(_inputController.text);
      _inputController.clear();
    }
  }

  void _onBack() {
    widget.model.prevStep();
    final field = widget.model.currentField;
    if (field.isNotEmpty && widget.model.measurements.containsKey(field)) {
      _inputController.text = widget.model.measurements[field] ?? '';
    }
  }

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
                              onCaliperCheckPressed: _initiateCaliperCheck,
                              caliperFocusNode: _caliperFocusNode,
                              isCaliperChecking: _isCaliperChecking,
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
    final field = widget.model.currentField;
    if (field.isNotEmpty && widget.model.measurements.containsKey(field)) {
      _inputController.text = widget.model.measurements[field] ?? '';
    }
  }
}
