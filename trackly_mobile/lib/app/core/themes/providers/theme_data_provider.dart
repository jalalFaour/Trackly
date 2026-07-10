import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app_themes.dart';
import '../themes_data/theme01/theme_data_01_dark.dart';
import '../themes_data/theme01/theme_data_01_light.dart';
import '../themes_data/theme02/theme_data_02_dark.dart';
import '../themes_data/theme02/theme_data_02_light.dart';
import 'theme_name_provider.dart';

final themeDataProvider = Provider.family<ThemeData, ThemeMode>(
  (ref, themeMode) {
    final themeName = ref.watch(
      themeNameProvider,
    );

    final isDarkModeCondition = themeMode == ThemeMode.dark;

    if (themeName == AppThemesKeys.theme01) {
      return isDarkModeCondition ? themeData01Dark : themeData01Light;
    }

    if (themeName == AppThemesKeys.theme02) {
      return isDarkModeCondition ? themeData02Dark : themeData02Light;
    }

    return isDarkModeCondition ? themeData01Dark : themeData01Light;
  },
);
