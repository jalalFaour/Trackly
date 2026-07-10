import 'package:flutter/material.dart';

import '../core/values/app_dimensions.dart';

class AppTextWidget extends StatelessWidget {
  final String text;
  final Color? color;
  final TextStyle? style;
  final TextDirection textDirection;
  final int? maxLines;
  final TextOverflow overflow;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? letterSpacing;
  final TextAlign? textAlign;
  final String? fontFamily;

  const AppTextWidget({
    super.key,
    required this.text,
    this.color,
    this.style,
    this.textDirection = TextDirection.ltr,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.fontSize,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.start,
    this.letterSpacing,
    this.fontFamily,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Text(
      text,
      style:
          style ??
          TextStyle(
            color: color,
            fontSize: fontSize ?? AppDimensions.fontSize16,
            fontWeight: fontWeight,
            letterSpacing: letterSpacing,
            fontFamily: fontFamily
          ),
      textDirection: textDirection,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
