import 'package:flutter/material.dart';

import '../core/values/app_colors.dart';
import '../core/values/app_dimensions.dart';
import 'app_icon_widget.dart';

class AppCircleButtonWidget extends StatelessWidget {
  final IconData iconData;
  final Color iconColor;
  final double iconSize;
  final void Function() onPressed;
  final Color backgroundColor;
  final double? backgroundSize;
  final bool isBordered;
  final Color? borderColor; // Added optional parameter

  const AppCircleButtonWidget({
    super.key,
    required this.iconData,
    this.iconColor = AppColors.black01,
    this.iconSize = AppDimensions.iconSize30,
    required this.onPressed,
    this.backgroundColor = AppColors.transparent,
    this.backgroundSize,
    this.isBordered = false,
    this.borderColor, // Initialize here
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: backgroundSize,
      height: backgroundSize,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: isBordered
            ? Border.all(
                color:
                    borderColor ??
                    AppColors.primary, // Use optional color or default
                width: 1.0,
              )
            : null,
      ),
      child: IconButton(
        icon: Center(
          child: AppIconWidget(
            iconData: iconData,
            size: iconSize,
            color: iconColor,
          ),
        ),
        iconSize: iconSize,
        onPressed: onPressed,
      ),
    );
  }
}
