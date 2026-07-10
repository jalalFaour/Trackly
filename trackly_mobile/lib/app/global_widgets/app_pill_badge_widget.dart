import 'package:flutter/material.dart';

class AppPillBadgeWidget extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool isSelected;

  const AppPillBadgeWidget({
    super.key,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Default to primary color if selected, otherwise a subtle gray
    final effectiveBgColor =
        backgroundColor ??
        (isSelected ? theme.colorScheme.primary : Colors.grey.shade200);

    // Default to white text if selected (on primary), otherwise theme's default text color
    final effectiveFgColor =
        foregroundColor ??
        (isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface);

    // The core pill container
    final decoratedChild = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(
          9999,
        ), // Creates the perfect pill shape
      ),
      child: DefaultTextStyle(
        // Applies the foreground color to any Text widgets inside the child
        style:
            theme.textTheme.labelMedium?.copyWith(
              color: effectiveFgColor,
              fontWeight: FontWeight.w600,
            ) ??
            TextStyle(color: effectiveFgColor, fontWeight: FontWeight.w600),
        child: child,
      ),
    );

    // If interactive, wrap in Material + InkWell for the ripple effect
    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        shape:
            const StadiumBorder(), // Ensures the splash ripple is also pill-shaped
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9999),
          child: decoratedChild,
        ),
      );
    }

    return decoratedChild;
  }
}
