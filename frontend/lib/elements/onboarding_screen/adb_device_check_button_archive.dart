import 'package:flutter/material.dart';
import 'dart:io';

class AdbDeviceCheckButton extends StatefulWidget {
  final bool enabled;
  final VoidCallback onComplete;
  final Color buttonBg;
  final Color buttonFg;
  const AdbDeviceCheckButton({
    required this.enabled,
    required this.onComplete,
    required this.buttonBg,
    required this.buttonFg,
    super.key,
  });

  @override
  State<AdbDeviceCheckButton> createState() => _AdbDeviceCheckButtonState();
}

class _AdbDeviceCheckButtonState extends State<AdbDeviceCheckButton> {
  bool _morphed = false;
  bool _checking = false;
  String? _error;

  Future<void> _checkAdbDevices() async {
    // Logging: Step 2 device check started
    // ignore: avoid_print
    print('[LOG] Step 2: Checking for ADB devices...');
    setState(() {
      _checking = true;
      _error = null;
    });
    try {
      final result = await Process.run('adb', ['devices']);
      final output = result.stdout.toString();
      final lines = output.split('\n');
      final deviceLines = lines.where((line) =>
        line.trim().isNotEmpty &&
        !line.contains('List of devices') &&
        !line.contains('attached') &&
        !line.contains('offline') &&
        !line.contains('unauthorized')
      ).toList();
      if (deviceLines.isNotEmpty) {
        // Logging: Device found
        // ignore: avoid_print
        print('[LOG] Step 2: Device(s) found: \\${deviceLines.join(', ')}');
        setState(() {
          _morphed = true;
        });
      } else {
        // Logging: No device found
        // ignore: avoid_print
        print('[LOG] Step 2: No device detected');
        setState(() {
          _error = 'No device detected';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No device detected')),
        );
      }
    } catch (e) {
      // Logging: ADB not found or failed
      // ignore: avoid_print
      print('[LOG] Step 2: ADB not found or failed to run');
      setState(() {
        _error = 'ADB not found or failed to run';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ADB not found or failed to run')),
      );
    } finally {
      setState(() {
        _checking = false;
      });
    }
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
                      'Device Connected!',
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
                        // Logging: Step 2 continue pressed
                        // ignore: avoid_print
                        print('[LOG] Step 2: Continue pressed after device connected');
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
                onTap: widget.enabled && !_checking ? _checkAdbDevices : null,
                child: Center(
                  child: _checking
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Check Device',
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