import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/values/app_colors.dart';
import 'app_icon_widget.dart';

class AppImageWidget extends StatelessWidget {
  final String path; // File, Assets and Url
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius; // Added parameter

  const AppImageWidget({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0.0, // Default to 0
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final pathToCompare = path.toLowerCase();
    final isAssets = pathToCompare.startsWith('assets');
    final isNetwork = pathToCompare.startsWith('http');

    Widget imageWidget;

    if (isAssets) {
      imageWidget = Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
      );
    } else if (isNetwork) {
      imageWidget = CachedNetworkImage(
        imageUrl: path,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
        errorWidget: (context, url, error) => const Center(
          child: AppIconWidget(
            iconData: Icons.error,
            color: AppColors.red01,
          ),
        ),
      );
    } else {
      imageWidget = Image.file(
        File(path),
        width: width,
        height: height,
        fit: fit,
      );
    }

    // Wrap the result with ClipRRect to apply the radius
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        borderRadius,
      ),
      child: imageWidget,
    );
  }
}
