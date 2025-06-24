import 'package:flutter/material.dart';

class StepCircle extends StatelessWidget {
  final bool isCompleted;
  final bool isActive;
  final String label;
  const StepCircle({required this.isCompleted, required this.isActive, required this.label});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (isCompleted) {
      color = const Color(0xFF4CAF50); // Green
    } else if (isActive) {
      color = const Color(0xFF2196F3); // Blue
    } else {
      color = const Color(0xFFE0E0E0); // Gray
    }
    Color textColor = (isCompleted || isActive) ? Colors.white : Colors.black;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: !isCompleted && !isActive
            ? Border.all(color: const Color(0xFFBDBDBD), width: 2)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}

class StepLine extends StatelessWidget {
  final bool isActive;
  const StepLine({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      color: isActive ? const Color(0xFF2196F3) : const Color(0xFFBDBDBD),
    );
  }
} 