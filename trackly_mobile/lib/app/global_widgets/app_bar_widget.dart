import 'package:flutter/material.dart';
import 'package:trackly/app/core/extensions/context_extensions.dart';

import '../core/values/app_dimensions.dart';
import 'app_text_widget.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final Color? backgroundColor;
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;
  final Widget? leading;
  final double elevation;
  final bool automaticallyImplyLeading;

  const AppBarWidget({
    super.key,
    this.backgroundColor,
    this.title = '',
    this.centerTitle =
        false, // Default to false for modern left-aligned typography
    this.actions,
    this.leading,
    this.elevation = 0.0,
    this.automaticallyImplyLeading = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return AppBar(
      backgroundColor:
          backgroundColor ?? theme.appBarTheme.backgroundColor ?? Colors.white,
      elevation: elevation,
      scrolledUnderElevation:
          0.0, // Prevents tint shifts when content scrolls beneath
      titleSpacing: 0, // Clears default spacing to allow precise padding layout
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingOrMargin14,
        ),
        child: AppTextWidget(
          text: title,
          color: context.theme.colorScheme.primary,
          fontSize:
              theme.appBarTheme.titleTextStyle?.fontSize ??
              AppDimensions.fontSize24,
          fontWeight:
              theme.appBarTheme.titleTextStyle?.fontWeight ?? FontWeight.bold,
        ),
      ),
    );
  }
}
