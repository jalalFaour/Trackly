import 'package:flutter/material.dart';
import 'package:trackly/app/core/extensions/context_extensions.dart';

import '../core/values/app_dimensions.dart';

class AppCardWidget extends StatelessWidget {
  final Color? color;
  final double borderRadius;
  final bool isBordered;
  final Color? borderColor;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool? showShadow;
  final List<BoxShadow>? customBoxShadow;

  const AppCardWidget({
    this.color,
    this.borderRadius = AppDimensions.paddingOrMargin08,
    this.isBordered = false,
    this.borderColor,
    this.child,
    this.padding,
    this.margin,
    this.showShadow,
    this.customBoxShadow,
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final modernShadow = [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];

    final bool hasShadow = showShadow ?? !isBordered;

    return Container(
      margin: margin,
      padding:
          padding ??
          const EdgeInsets.all(
            AppDimensions.paddingOrMargin12,
          ),
      decoration: BoxDecoration(
        color: color ?? context.theme.cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: isBordered
            ? Border.all(
                color: borderColor ?? context.theme.colorScheme.primary,
                width: 1,
              )
            : null,
        boxShadow: customBoxShadow ?? (hasShadow ? modernShadow : []),
      ),
      child: child,
    );
  }
}
