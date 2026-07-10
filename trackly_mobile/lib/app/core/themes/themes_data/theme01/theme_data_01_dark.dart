import 'package:flutter/material.dart';
import 'theme_01_scheme_dark.dart';

const _darkRadius = 16.0;

final themeData01Dark = ThemeData(
  useMaterial3: true,
  colorScheme: theme01SchemeDark,
  scaffoldBackgroundColor: theme01SchemeDark.surface,
  appBarTheme: AppBarTheme(
    backgroundColor: theme01SchemeDark.surface,
    foregroundColor: theme01SchemeDark.onSurface,
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0.5,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(
      color: theme01SchemeDark.onSurface,
      fontSize: 19,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    ),
  ),
  cardTheme: CardThemeData(
    color: theme01SchemeDark.surfaceContainerHighest.withValues(alpha: 0.3),
    elevation: 1,
    shadowColor: Colors.black.withValues(alpha: 0.2),
    surfaceTintColor: theme01SchemeDark.surfaceTint,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_darkRadius),
      side: BorderSide(
        color: theme01SchemeDark.outline.withValues(alpha: 0.12),
      ),
    ),
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: theme01SchemeDark.primary,
      foregroundColor: theme01SchemeDark.onPrimary,
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: theme01SchemeDark.primary,
      foregroundColor: theme01SchemeDark.onPrimary,
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: theme01SchemeDark.primary,
      minimumSize: const Size.fromHeight(52),
      side: BorderSide(
        color: theme01SchemeDark.primary.withValues(alpha: 0.45),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: theme01SchemeDark.surfaceContainerHighest.withValues(alpha: 0.4),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: theme01SchemeDark.outline.withValues(alpha: 0.25),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: theme01SchemeDark.outline.withValues(alpha: 0.2),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: theme01SchemeDark.primary, width: 1.8),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: theme01SchemeDark.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: theme01SchemeDark.error, width: 1.8),
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: theme01SchemeDark.surface,
    indicatorColor: theme01SchemeDark.primaryContainer,
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return IconThemeData(color: theme01SchemeDark.onPrimaryContainer);
      }
      return IconThemeData(color: theme01SchemeDark.onSurfaceVariant);
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      return TextStyle(
        fontWeight: states.contains(WidgetState.selected)
            ? FontWeight.w700
            : FontWeight.w500,
        color: states.contains(WidgetState.selected)
            ? theme01SchemeDark.onSurface
            : theme01SchemeDark.onSurfaceVariant,
      );
    }),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: theme01SchemeDark.surfaceContainerHighest,
    selectedColor: theme01SchemeDark.primaryContainer,
    disabledColor: theme01SchemeDark.surfaceContainerHighest.withValues(
      alpha: 0.3,
    ),
    labelStyle: TextStyle(color: theme01SchemeDark.onSurfaceVariant),
    secondaryLabelStyle: TextStyle(
      color: theme01SchemeDark.onPrimaryContainer,
    ),
    side: BorderSide(color: theme01SchemeDark.outline.withValues(alpha: 0.2)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: theme01SchemeDark.primary,
    foregroundColor: theme01SchemeDark.onPrimary,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    elevation: 1,
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: theme01SchemeDark.inverseSurface,
    contentTextStyle: TextStyle(color: theme01SchemeDark.onInverseSurface),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: theme01SchemeDark.surface,
    surfaceTintColor: theme01SchemeDark.surfaceTint,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  ),
  dividerTheme: DividerThemeData(
    color: theme01SchemeDark.outline.withValues(alpha: 0.2),
    thickness: 1,
    space: 1,
  ),
);
