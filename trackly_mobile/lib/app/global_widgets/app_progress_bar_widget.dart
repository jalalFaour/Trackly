import 'package:flutter/material.dart';

class AppProgressBarWidget extends StatelessWidget {
  final int progress; // 1 to 100
  final Color activeColor;
  final Color trackColor;
  final double height;

  const AppProgressBarWidget({
    super.key,
    required this.progress,
    this.activeColor = Colors.blue,
    this.trackColor = const Color(0xFFEEEEEE),
    this.height = 8.0,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    // Clamp the value to ensure it stays between 0 and 100
    final double normalizedValue = progress.clamp(0, 100) / 100.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: normalizedValue,
        minHeight: height,
        backgroundColor: trackColor,
        valueColor: AlwaysStoppedAnimation<Color>(activeColor),
      ),
    );
  }
}
