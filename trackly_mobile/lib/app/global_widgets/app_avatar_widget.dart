import 'package:flutter/material.dart';

import '../core/values/app_colors.dart';
import '../core/values/app_dimensions.dart';
import 'app_image_widget.dart';

class AppAvatarWidget extends StatelessWidget {
  final String imageUrl;
  final bool isStatusShown;
  final Color statusColor;
  final bool isBordered;
  final Color borderColor;
  final double borderThickness;
  final double radius;

  const AppAvatarWidget({
    super.key,
    required this.imageUrl,
    this.isStatusShown = false,
    this.statusColor = AppColors.green,
    this.isBordered = false,
    this.borderColor = AppColors.primary,
    this.borderThickness = AppDimensions.thickness02,
    this.radius = AppDimensions.radius20,
  }) : assert(
         radius > borderThickness,
         'Radius must be greater than',
       );

  @override
  Widget build(
    BuildContext context,
  ) {
    final imageRadius = isBordered ? radius - borderThickness : radius;

    return Stack(
      children: [
        // Background & Image
        CircleAvatar(
          radius: radius,
          backgroundColor: borderColor,
          child: CircleAvatar(
            radius: imageRadius,
            backgroundColor: AppColors.gray01,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                imageRadius,
              ),
              child: AppImageWidget(
                path: imageUrl,
                width: imageRadius * 2,
                height: imageRadius * 2,
              ),
            ),
          ),
        ),

        // Status
        if (isStatusShown)
          PositionedDirectional(
            end: AppDimensions.zero,
            bottom: AppDimensions.zero,
            child: Container(
              width: AppDimensions.width15,
              height: AppDimensions.height15,
              decoration: BoxDecoration(
                color: statusColor.withValues(
                  alpha: 1.0,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  width: AppDimensions.thickness02,
                  color: AppColors.white01,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
