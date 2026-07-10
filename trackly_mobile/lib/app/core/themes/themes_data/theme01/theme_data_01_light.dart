import 'package:flutter/material.dart';
import 'theme_01_scheme_light.dart';

const _lightRadius = 16.0;

final themeData01Light = ThemeData(
  useMaterial3: true,
  colorScheme: theme01SchemeLight,
  scaffoldBackgroundColor: theme01SchemeLight.surface,
  appBarTheme: AppBarTheme(
    backgroundColor: theme01SchemeLight.surface,
    foregroundColor: theme01SchemeLight.onSurface,
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0.5,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(
      color: theme01SchemeLight.onSurface,
      fontSize: 19,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    ),
  ),
  cardTheme: CardThemeData(
    color: theme01SchemeLight.surface,
    elevation: 1,
    shadowColor: Colors.black.withValues(alpha: 0.08),
    surfaceTintColor: theme01SchemeLight.surfaceTint,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_lightRadius),
      side: BorderSide(
        color: theme01SchemeLight.outline.withValues(alpha: 0.16),
      ),
    ),
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: theme01SchemeLight.primary,
      foregroundColor: theme01SchemeLight.onPrimary,
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: theme01SchemeLight.primary,
      foregroundColor: theme01SchemeLight.onPrimary,
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: theme01SchemeLight.primary,
      minimumSize: const Size.fromHeight(52),
      side: BorderSide(
        color: theme01SchemeLight.primary.withValues(alpha: 0.45),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: theme01SchemeLight.surfaceContainerHighest.withValues(
      alpha: 0.4,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: theme01SchemeLight.outline.withValues(alpha: 0.35),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: theme01SchemeLight.outline.withValues(alpha: 0.3),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: theme01SchemeLight.primary, width: 1.8),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: theme01SchemeLight.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: theme01SchemeLight.error, width: 1.8),
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: theme01SchemeLight.surface,
    indicatorColor: theme01SchemeLight.primaryContainer,
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return IconThemeData(color: theme01SchemeLight.onPrimaryContainer);
      }
      return IconThemeData(color: theme01SchemeLight.onSurfaceVariant);
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      return TextStyle(
        fontWeight: states.contains(WidgetState.selected)
            ? FontWeight.w700
            : FontWeight.w500,
        color: states.contains(WidgetState.selected)
            ? theme01SchemeLight.onSurface
            : theme01SchemeLight.onSurfaceVariant,
      );
    }),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: theme01SchemeLight.surfaceContainerHighest,
    selectedColor: theme01SchemeLight.primaryContainer,
    disabledColor: theme01SchemeLight.surfaceContainerHighest.withValues(
      alpha: 0.5,
    ),
    labelStyle: TextStyle(color: theme01SchemeLight.onSurfaceVariant),
    secondaryLabelStyle: TextStyle(
      color: theme01SchemeLight.onPrimaryContainer,
    ),
    side: BorderSide(color: theme01SchemeLight.outline.withValues(alpha: 0.25)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: theme01SchemeLight.primary,
    foregroundColor: theme01SchemeLight.onPrimary,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    elevation: 1,
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: theme01SchemeLight.inverseSurface,
    contentTextStyle: TextStyle(color: theme01SchemeLight.onInverseSurface),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: theme01SchemeLight.surface,
    surfaceTintColor: theme01SchemeLight.surfaceTint,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  ),
  dividerTheme: DividerThemeData(
    color: theme01SchemeLight.outline.withValues(alpha: 0.25),
    thickness: 1,
    space: 1,
  ),
);
