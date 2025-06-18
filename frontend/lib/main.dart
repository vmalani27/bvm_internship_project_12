import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const VernierCaliperApp());
}

class VernierCaliperApp extends StatelessWidget {
  const VernierCaliperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vernier Caliper Simulator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const VernierCaliperPage(),
    );
  }
}

class VernierCaliperPage extends StatefulWidget {
  const VernierCaliperPage({super.key});

  @override
  State<VernierCaliperPage> createState() => _VernierCaliperPageState();
}

class _VernierCaliperPageState extends State<VernierCaliperPage> {
  // Caliper state variables
  double mainScaleDivisions = 50;
  double vernierScaleDivisions = 10;
  double zeroError = 0;
  double msr = 0; // Main Scale Reading
  double vsr = 0; // Vernier Scale Reading
  double scale = 1.0;
  double rotationAngle = 0;
  bool showVirtualDivisions = false;
  bool displayValues = false;
  bool randomZeroError = false;
  bool randomMSD = false;
  bool randomVSD = false;
  bool randomObject = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vernier Caliper Simulator'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              setState(() {
                scale = (scale * 1.1).clamp(0.5, 3.0);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              setState(() {
                scale = (scale / 1.1).clamp(0.5, 3.0);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                rotationAngle = 0;
                scale = 1.0;
              });
            },
          ),
        ],
      ),
      drawer: _buildSidebar(),
      body: Row(
        children: [
          // Main canvas area
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CustomPaint(
                      painter: VernierCaliperPainter(
                        mainScaleDivisions: mainScaleDivisions,
                        vernierScaleDivisions: vernierScaleDivisions,
                        zeroError: zeroError,
                        msr: msr,
                        vsr: vsr,
                        scale: scale,
                        rotationAngle: rotationAngle,
                        showVirtualDivisions: showVirtualDivisions,
                        displayValues: displayValues,
                      ),
                      child: GestureDetector(
                        onScaleUpdate: (details) {
                          setState(() {
                            // Move vernier with horizontal pan (details.focalPointDelta.dx)
                            vsr += details.focalPointDelta.dx * 0.1;
                            if (vsr >= vernierScaleDivisions) {
                              vsr = 0;
                              msr += 1;
                            } else if (vsr < 0) {
                              vsr = vernierScaleDivisions - 1;
                              msr = math.max(0, msr - 1);
                            }
                            // Rotate with pinch
                            rotationAngle += details.rotation;
                          });
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
      floatingActionButton: FloatingActionButton(
        onPressed: _createProblem,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSidebar() {
    return Drawer(
      child: Column(
        children: [
          // Header
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vernier Caliper',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Interactive Measurement Simulator',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Device Settings
                  _buildSectionTitle('Device Settings'),
                  _buildCard([
                    _buildSlider(
                      'Main Scale Divisions',
                      mainScaleDivisions,
                      20,
                      100,
                      10,
                      (value) => setState(() => mainScaleDivisions = value),
                    ),
                    _buildSlider(
                      'Vernier Scale Divisions',
                      vernierScaleDivisions,
                      5,
                      25,
                      5,
                      (value) => setState(() => vernierScaleDivisions = value),
                    ),
                    _buildSlider(
                      'Zero Error',
                      zeroError,
                      -9,
                      9,
                      1,
                      (value) => setState(() => zeroError = value),
                    ),
                    const Divider(),
                    _buildCheckbox(
                      'Show Virtual Divisions',
                      showVirtualDivisions,
                      (value) => setState(() => showVirtualDivisions = value),
                    ),
                    _buildCheckbox(
                      'Display Values',
                      displayValues,
                      (value) => setState(() => displayValues = value),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Problem Settings
                  _buildSectionTitle('Problem Settings'),
                  _buildCard([
                    _buildCheckbox(
                      'Randomize Zero Error',
                      randomZeroError,
                      (value) => setState(() => randomZeroError = value),
                    ),
                    _buildCheckbox(
                      'Randomize MSD Count',
                      randomMSD,
                      (value) => setState(() => randomMSD = value),
                    ),
                    _buildCheckbox(
                      'Randomize VSD Count',
                      randomVSD,
                      (value) => setState(() => randomVSD = value),
                    ),
                    _buildCheckbox(
                      'Randomize Object Size',
                      randomObject,
                      (value) => setState(() => randomObject = value),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _createProblem,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Create Problem'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Controls
                  _buildSectionTitle('Controls'),
                  _buildCard([
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            rotationAngle = 0;
                            scale = 1.0;
                          });
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Reset Rotation'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showHelp,
                        icon: const Icon(Icons.help, size: 18),
                        label: const Text('Help & Instructions'),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Current Reading Display
                  _buildSectionTitle('Current Reading'),
                  _buildCard([
                    _buildReadingDisplay('Main Scale', msr.toStringAsFixed(0)),
                    _buildReadingDisplay('Vernier Scale', vsr.toStringAsFixed(0)),
                    _buildReadingDisplay('Total Reading', _calculateTotalReading()),
                    _buildReadingDisplay('Zero Error', zeroError.toStringAsFixed(0)),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, double step, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) / step).round(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (newValue) => onChanged(newValue ?? false),
          ),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingDisplay(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateTotalReading() {
    double msdValue = 0.1; // 1 MSD = 0.1 cm
    double totalReading = (msr + vsr / vernierScaleDivisions) * msdValue;
    return '${totalReading.toStringAsFixed(3)} cm';
  }

  void _createProblem() {
    setState(() {
      if (randomMSD) {
        mainScaleDivisions = (50 * (1 + (2 * math.Random().nextDouble()).round())) as double;
      }
      if (randomVSD) {
        vernierScaleDivisions = (1 + (math.Random().nextDouble() * 5).round()) * 5;
      }
      if (randomZeroError) {
        zeroError = (2 * vernierScaleDivisions * (math.Random().nextDouble() - 0.5)).round().toDouble();
      }
      // Reset readings
      msr = 0;
      vsr = 0;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New problem created!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Instructions'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How to Use:'),
              SizedBox(height: 8),
              Text('• Drag on the caliper to move the vernier scale'),
              Text('• Use pinch gestures to rotate the caliper'),
              Text('• Adjust settings in the sidebar'),
              Text('• Click "Create Problem" for random scenarios'),
              SizedBox(height: 16),
              Text('Controls:'),
              SizedBox(height: 8),
              Text('• Mouse/Touch: Move vernier'),
              Text('• Pinch: Rotate caliper'),
              Text('• Sliders: Adjust divisions and zero error'),
              Text('• Checkboxes: Toggle features'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class VernierCaliperPainter extends CustomPainter {
  final double mainScaleDivisions;
  final double vernierScaleDivisions;
  final double zeroError;
  final double msr;
  final double vsr;
  final double scale;
  final double rotationAngle;
  final bool showVirtualDivisions;
  final bool displayValues;

  VernierCaliperPainter({
    required this.mainScaleDivisions,
    required this.vernierScaleDivisions,
    required this.zeroError,
    required this.msr,
    required this.vsr,
    required this.scale,
    required this.rotationAngle,
    required this.showVirtualDivisions,
    required this.displayValues,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Apply transformations
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);
    canvas.rotate(rotationAngle);
    canvas.translate(-size.width / 2, -size.height / 2);

    // Background
    final backgroundPaint = Paint()
      ..color = const Color(0xFF004054);
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    // Draw a simple representation of the vernier caliper
    _drawCaliper(canvas, size);
    
    canvas.restore();
  }

  void _drawCaliper(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Main scale (horizontal line)
    final mainScaleY = size.height * 0.6;
    canvas.drawLine(
      Offset(50, mainScaleY),
      Offset(size.width - 50, mainScaleY),
      paint,
    );

    // Vernier scale (slightly offset)
    final vernierY = mainScaleY + 20;
    final vernierOffset = (msr + vsr / vernierScaleDivisions) * 10; // Simplified calculation
    canvas.drawLine(
      Offset(50 + vernierOffset, vernierY),
      Offset(size.width - 50 + vernierOffset, vernierY),
      paint..color = Colors.white,
    );

    // Draw some tick marks
    for (int i = 0; i <= mainScaleDivisions; i++) {
      final x = 50 + (i * (size.width - 100) / mainScaleDivisions);
      final tickLength = i % 5 == 0 ? 15.0 : 8.0;
      
      canvas.drawLine(
        Offset(x, mainScaleY - tickLength),
        Offset(x, mainScaleY + tickLength),
        paint..color = Colors.white,
      );

      // Draw labels for major ticks
      if (i % 5 == 0 && displayValues) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: (i * 0.1).toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, mainScaleY - tickLength - 20),
        );
      }
    }

    // Draw vernier scale ticks
    for (int i = 0; i <= vernierScaleDivisions; i++) {
      final x = 50 + vernierOffset + (i * (size.width - 100) / mainScaleDivisions * (1 - 1 / vernierScaleDivisions));
      final tickLength = i % 2 == 0 ? 10.0 : 5.0;
      
      canvas.drawLine(
        Offset(x, vernierY - tickLength),
        Offset(x, vernierY + tickLength),
        paint..color = Colors.yellow,
      );
    }

    // Draw reading display
    if (displayValues) {
      final readingText = 'MSR: ${msr.toStringAsFixed(0)} | VSR: ${vsr.toStringAsFixed(0)} | Total: ${_calculateTotalReading()}';
      final textPainter = TextPainter(
        text: TextSpan(
          text: readingText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(20, 20),
      );
    }

    // Draw rotation indicator
    final rotationText = 'Rotation: ${(rotationAngle * 180 / math.pi).toStringAsFixed(1)}°';
    final rotationTextPainter = TextPainter(
      text: TextSpan(
        text: rotationText,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    rotationTextPainter.layout();
    rotationTextPainter.paint(
      canvas,
      Offset(20, size.height - 40),
    );
  }

  String _calculateTotalReading() {
    double msdValue = 0.1; // 1 MSD = 0.1 cm
    double totalReading = (msr + vsr / vernierScaleDivisions) * msdValue;
    return '${totalReading.toStringAsFixed(3)} cm';
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 