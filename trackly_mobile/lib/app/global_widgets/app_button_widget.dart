import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../core/values/app_colors.dart';
import '../core/values/app_dimensions.dart';
import 'app_icon_widget.dart';
import 'app_text_widget.dart';

class AppButtonWidget extends StatelessWidget {
  final IconData? iconData;
  final Color iconColor;
  final String text;
  final Color textColor;
  final TextStyle? textStyle;
  // New sub-label parameters
  final String? subText;
  final Color subTextColor;
  final TextStyle? subTextStyle;

  final VoidCallback onPressed;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final IconAlignment? iconAlignment;

  const AppButtonWidget({
    super.key,
    this.iconData,
    this.iconColor = AppColors.white,
    required this.text,
    this.textColor = AppColors.white,
    this.textStyle,
    // Default sub-label color to gray
    this.subText,
    this.subTextColor = AppColors.gray03,
    this.subTextStyle,
    required this.onPressed,
    this.backgroundColor,
    this.width,
    this.height,
    this.iconAlignment = IconAlignment.start,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return TextButton.icon(
      onPressed: onPressed,
      style: ButtonStyle(
        iconAlignment: iconAlignment,
        backgroundColor: WidgetStatePropertyAll(
          backgroundColor ?? Theme.of(context).primaryColor,
        ),
        fixedSize: (width != null || height != null)
            ? WidgetStatePropertyAll(
                Size(
                  width ?? double.infinity,
                  height ?? double.infinity,
                ),
              )
            : null,
        alignment: Alignment.center,
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              8.0,
            ),
          ),
        ),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(
            horizontal: width != null ? 0 : 16.0,
            vertical: height != null ? 0 : 12.0,
          ),
        ),
      ),
      icon: iconData == null
          ? const SizedBox.shrink() // TextButton.icon expects a widget
          : AppIconWidget(
              iconData: iconData!,
              color: iconColor,
              size: AppDimensions.iconSize20,
            ),
      label: Column(
        mainAxisSize: MainAxisSize.min,
        // Aligns text to start/center based on button needs
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppTextWidget(
            text: text,
            color: textColor,
            style: textStyle,
          ),
          if (subText != null) ...[
            Gap(
              AppDimensions.paddingOrMargin04,
            ),
            AppTextWidget(
              text: subText!,
              color: subTextColor,
              style:
                  subTextStyle ??
                  TextStyle(
                    fontSize: 12,
                    color: subTextColor,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
