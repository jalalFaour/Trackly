
import 'package:flutter/material.dart';
import 'package:trackly/app/core/extensions/context_extensions.dart';

import '../core/values/app_colors.dart';
import '../core/values/app_dimensions.dart';

class AppTextFieldWidget extends StatelessWidget {
  final TextEditingController textEditingController;
  final String? hintText;
  final InputDecoration? inputDecoration;
  final bool obscureText;
  final Color? fillColor;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;

  const AppTextFieldWidget({
    super.key,
    required this.textEditingController,
    this.hintText,
    this.inputDecoration,
    this.obscureText = false,
    this.fillColor,
    this.suffix,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    // Define the shared border style to maintain a clean look
    final borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        AppDimensions.radius12,
      ),
      borderSide: BorderSide.none, // Invisible border for a soft look
    );

    return TextField(
      controller: textEditingController,
      obscureText: obscureText,
      style: const TextStyle(
        fontSize: AppDimensions.fontSize14,
      ), // Modernized text scale
      decoration:
          inputDecoration ??
          InputDecoration(
            filled: true,
            fillColor:
                fillColor ??
                context.theme.inputDecorationTheme.fillColor ??
                AppColors.gray02,
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontSize: AppDimensions.fontSize14,
            ),
            suffixIcon: suffix, // Changed to suffixIcon for better alignment
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingOrMargin16,
              vertical: AppDimensions.paddingOrMargin14,
            ),
            border: borderStyle,
            enabledBorder: borderStyle,
            focusedBorder: borderStyle.copyWith(
              borderSide: BorderSide(
                color: context.theme.colorScheme.primary,
                width: 1,
              ),
            ),
          ),
      onSubmitted: onSubmitted,
    );
  }
}
