import 'package:flutter/material.dart';

import '../core/values/app_colors.dart';
import '../core/values/app_dimensions.dart';

class AppIconWidget extends StatelessWidget {
  final IconData iconData;
  final Color color;
  final double size;
  final void Function()? onTap;

  // New optional properties
  final Color? backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const AppIconWidget({
    super.key,
    required this.iconData,
    this.color = AppColors.gray03,
    this.size = AppDimensions.iconSize24,
    this.onTap,
    // Defaults: Transparent background and 12 radius
    this.backgroundColor,
    this.borderRadius = AppDimensions.radius12,
    this.padding,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Icon(
          iconData,
          color: color,
          size: size,
        ),
      ),
    );
  }
}
