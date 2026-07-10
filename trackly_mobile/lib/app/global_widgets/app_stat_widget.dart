import 'package:flutter/material.dart';

import '../core/values/app_dimensions.dart';

class AppStatWidget extends StatelessWidget {
  final IconData iconData;
  final String title;
  final String value;

  const AppStatWidget({
    super.key,
    required this.iconData,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icon
        Icon(iconData, size: AppDimensions.iconSize26),

        // Title
        Text(
          title,
          style: TextStyle(
            fontSize: AppDimensions.fontSize16,
            fontWeight: FontWeight.w600,
          ),
        ),

        // Value
        Text(
          value,
          style: TextStyle(
            fontSize: AppDimensions.fontSize16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
