import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../core/values/app_colors.dart';
import '../core/values/app_dimensions.dart';
import 'app_icon_widget.dart';
import 'app_text_widget.dart';

class AppOutlinedButtonWidget extends StatelessWidget {
  final IconData? iconData;
  final Color iconColor;
  final double iconSize;
  final String? text;
  final Color textColor;
  final TextStyle? textStyle;
  final void Function()? onPressed;
  final double radius;
  final Color borderColor;
  final double borderThickness;

  const AppOutlinedButtonWidget({
    super.key,
    this.iconData,
    this.iconColor = AppColors.primary,
    this.iconSize = AppDimensions.iconSize36,
    this.text,
    this.textColor = AppColors.primary,
    this.textStyle,
    this.borderColor = AppColors.primary,
    required this.onPressed,
    this.radius = AppDimensions.radius08,
    this.borderThickness = AppDimensions.thickness01,
  }) : assert(
         iconData != null || text != null,
         'IconData or text must be not null',
       );

  @override
  Widget build(
    BuildContext context,
  ) {
    final isEnabled = onPressed != null;
    // final resolvedBorderColor = isEnabled ? borderColor : AppColors.gray02;
    final resolvedIconColor = isEnabled ? iconColor : AppColors.gray03;
    final resolvedTextColor = isEnabled ? textColor : AppColors.gray03;

    return OutlinedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        side: WidgetStateProperty.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.disabled)
                ? AppColors.gray02
                : borderColor,
            width: borderThickness,
          ),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              radius,
            ),
          ),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingOrMargin12,
          ),
        ),
      ),
      child: Row(
        children: [
          // Icon
          if (iconData != null)
            Center(
              child: AppIconWidget(
                iconData: iconData!,
                color: resolvedIconColor,
                size: iconSize,
              ),
            ),

          // Space
          if (iconData != null && text != null)
            const Gap(
              AppDimensions.paddingOrMargin04,
            ),

          // Text
          if (text != null)
            AppTextWidget(
              text: text ?? '',
              color: resolvedTextColor,
              style: textStyle,
              overflow: TextOverflow.visible,
            ),
        ],
      ),
    );
  }
}
