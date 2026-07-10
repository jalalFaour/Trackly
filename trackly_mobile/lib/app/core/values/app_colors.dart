import 'package:flutter/material.dart';

abstract class AppColors {
  // Core brand colors (slightly refined for modern contrast)
  static const primary = Color(0xFF0058BD);
  static const secondary = Color(0xFF144E90);
  static const secondaryAccent = Color(0xFFCBDDF0);
  static const messageBackgroundReciver = Color(0xFFFEECE8);
  static const white = Color(0xFFFFFFFF);
  static const orange = Color(0xFFF2994A);
  static const green = Color(0xFF27AE60);
  static const greenAccent = Color(0xFFB6E2D3);
  static const red = Color(0xFFEB5757);
  static const redAccent = Color(0xFFFFE5E5);
  static const purple = Color(0xFFAF37E2);
  static const black = Color(0xFF000000);
  static const redCustom = Color(0xFFE8D1EE);
  static const card = Color(0xFFE5EEF7);

  static const transparent = Colors.transparent;

  // Ripple / overlay
  static const primaryRipple = Color(0x333A6FD8);

  // Absolute colors (keep as-is conceptually)
  static const black01 = Color(0xFF000000);
  static const white01 = Color(0xFFFFFFFF);

  // Neutral grays (UI surfaces, borders, dividers, disabled states)
  static const gray01 = Color(0xFFF5F5F7); // background
  static const gray02 = Color(0xFFE0E0E5); // borders
  static const gray03 = Color(0xFF9E9E9E); // secondary text
  static const gray04 = Color(0xFF6B7280); // hint text
  static const gray05 = Color(0xFF374151); // body text
  static const gray06 = Color(0xFF1F2937); // headings

  // Status / feedback colors (with transparency for backgrounds)
  static const red01 = Color(0x33EB5757);
  static const green01 = Color(0x3327AE60);
  static const yellow01 = Color(0x33F2C94C);
  static const blue01 = Color(0x333A6FD8);
  static const pink01 = Color(0x33E84393);
  static const purple01 = Color(0x336C5CE7);

  // Solid semantic colors (commonly needed)
  static const success = Color(0xFF27AE60);
  static const warning = Color(0xFFF2C94C);
  static const error = Color(0xFFEB5757);
  static const info = Color(0xFF2D9CDB);

  // Text colors
  static const textPrimary = Color(0xFF0058BD);
  static const textSecondary = Color(0xFF6B7280);
  static const textDisabled = Color(0xFF9CA3AF);
  static const textOnPrimary = Color(0xFFFFFFFF);

  // Backgrounds
  static const background = Color(0xFFF6FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF1F5F9);

  // Borders & dividers
  static const border = Color(0xFFE5E7EB);
  static const divider = Color(0xFFCBD5E1);

  // Shadow colors (enhanced for better layering)
  static const shadowExtraLight = Color(0x0A000000);
  static const shadowLight = Color(0x1A000000);
  static const shadowMedium = Color(0x33000000);
  static const shadowStrong = Color(0x66000000);

  // Colored shadows (modern design trend)
  static const shadowPrimary = Color(0x1A3A6FD8);
  static const shadowSuccess = Color(0x1A27AE60);
  static const shadowError = Color(0x1AEB5757);
  // Gradients
  static const linearGradient01 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3A6FD8),
      Color(0xFF6C5CE7),
    ],
  );

  static const linearGradient02 = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Color(0xCC000000),
      Color(0x66000000),
      Colors.transparent,
    ],
    stops: [
      0.0,
      0.5,
      1.0,
    ],
  );

  // Buttons
  static const buttonPrimary = primary;
  static const buttonDisabled = Color(0xFFCBD5E1);
  static const buttonTextDisabled = Color(0xFF9CA3AF);

  // Inputs
  static const inputFill = Color(0xFFF1F5F9);
  static const inputBorder = Color(0xFFCBD5E1);
  static const inputFocusedBorder = primary;
  static const inputErrorBorder = error;

  // Level 1: Subtle (buttons, cards, small elements)
  static const boxShadowXS = [
    BoxShadow(
      color: AppColors.shadowExtraLight,
      blurRadius: 2,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  // Level 2: Light elevation (cards, dialogs, modals)
  static const boxShadowSM = [
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 4,
      offset: Offset(0, 1),
      spreadRadius: -1,
    ),
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 6,
      offset: Offset(0, 2),
      spreadRadius: -2,
    ),
  ];

  // Level 3: Medium elevation (navigation, floating buttons)
  static const boxShadowMD = [
    BoxShadow(
      color: AppColors.shadowMedium,
      blurRadius: 10,
      offset: Offset(0, 4),
      spreadRadius: -3,
    ),
    BoxShadow(
      color: AppColors.shadowMedium,
      blurRadius: 4,
      offset: Offset(0, 2),
      spreadRadius: -2,
    ),
  ];

  // Level 4: High elevation (dropdowns, popovers, tooltips)
  static const boxShadowLG = [
    BoxShadow(
      color: AppColors.shadowMedium,
      blurRadius: 20,
      offset: Offset(0, 10),
      spreadRadius: -5,
    ),
    BoxShadow(
      color: AppColors.shadowMedium,
      blurRadius: 8,
      offset: Offset(0, 4),
      spreadRadius: -4,
    ),
  ];

  // Level 5: Very high elevation (modal bottomsheets, drawers)
  static const boxShadowXL = [
    BoxShadow(
      color: AppColors.shadowStrong,
      blurRadius: 32,
      offset: Offset(0, 20),
      spreadRadius: -12,
    ),
    BoxShadow(
      color: AppColors.shadowStrong,
      blurRadius: 12,
      offset: Offset(0, 8),
      spreadRadius: -6,
    ),
  ];

  // Level 6: Extreme elevation (toasts, floating action buttons)
  static const boxShadowXXL = [
    BoxShadow(
      color: AppColors.shadowStrong,
      blurRadius: 48,
      offset: Offset(0, 24),
      spreadRadius: -16,
    ),
    BoxShadow(
      color: AppColors.shadowStrong,
      blurRadius: 16,
      offset: Offset(0, 12),
      spreadRadius: -8,
    ),
  ];

  // Colored shadows (for special emphasis)
  static List<BoxShadow> boxShadowColored({
    Color color = AppColors.shadowPrimary,
    double blurRadius = 12,
    double spreadRadius = -4,
    Offset offset = const Offset(0, 6),
  }) {
    return [
      BoxShadow(
        color: color,
        blurRadius: blurRadius,
        offset: offset,
        spreadRadius: spreadRadius,
      ),
    ];
  }
}
