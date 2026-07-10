import 'package:flutter/material.dart';

import '../core/values/app_dimensions.dart';

class AppProgressWidget extends StatelessWidget {
  final double? size;
  final double? strokeWidth;
  final Color? color;

  const AppProgressWidget({
    super.key,
    this.size,
    this.strokeWidth,
    this.color,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: SizedBox(
        height: size ?? AppDimensions.iconSize24,
        width: size ?? AppDimensions.iconSize24,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth ?? AppDimensions.thickness02,
          valueColor: color != null
              ? AlwaysStoppedAnimation<Color>(
                  color!,
                )
              : null,
        ),
      ),
    );
  }
}
