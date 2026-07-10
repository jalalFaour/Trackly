import 'package:flutter/material.dart';

class AppStarWidget extends StatelessWidget {
  final bool isSelected;
  final Color? color;

  const AppStarWidget({
    super.key,
    this.isSelected = true,
    this.color,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Icon(
      isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
      color: color ?? Colors.yellow,
    );
  }
}
