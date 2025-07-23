import 'package:flutter/material.dart';
import 'package:hid4flutter/hid4flutter.dart';

class MorphingCalibrationButton extends StatefulWidget {
  final bool enabled;
  final VoidCallback onComplete;
  final Color buttonBg;
  final Color buttonFg;
  final OutlinedBorder buttonBorder;
  const MorphingCalibrationButton({
    required this.enabled,
    required this.onComplete,
    required this.buttonBg,
    required this.buttonFg,
    required this.buttonBorder,
    super.key,
  });

  @override
  State<MorphingCalibrationButton> createState() => _MorphingCalibrationButtonState();
}

class _MorphingCalibrationButtonState extends State<MorphingCalibrationButton> {
  bool _morphed = false;
  bool _calibrating = false;

  void _startCalibration() async {
    if (!widget.enabled) return;
    setState(() {
      _calibrating = true;
    });
    // Simulate calibration delay
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _morphed = true;
      _calibrating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      width: _morphed ? 260 : 140,
      height: _morphed ? 140 : 56,
      decoration: BoxDecoration(
        color: widget.buttonBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _morphed
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
        border: widget.buttonBorder is RoundedRectangleBorder && !_morphed && (widget.buttonBorder as RoundedRectangleBorder).side != BorderSide.none
            ? Border.all(
                color: (widget.buttonBorder as RoundedRectangleBorder).side.color,
                width: (widget.buttonBorder as RoundedRectangleBorder).side.width,
              )
            : null,
      ),
      child: _morphed
          ? Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Calibrated!',
                      style: TextStyle(
                        color: widget.buttonFg,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.buttonFg,
                        foregroundColor: widget.buttonBg,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // Logging: Step 3 continue pressed
                        // ignore: avoid_print
                        print('[LOG] Step 3: Continue pressed after calibration');
                        setState(() {
                          _morphed = false;
                        });
                        Future.delayed(const Duration(milliseconds: 350), widget.onComplete);
                      },
                      child: const Text('Continue'),
                    ),
                  ],
                ),
              ),
            )
          : Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: widget.enabled && !_calibrating ? _startCalibration : null,
                child: Center(
                  child: _calibrating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Calibration',
                          style: TextStyle(
                            color: widget.buttonFg,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ),
    );
  }
} 