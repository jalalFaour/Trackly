import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../storage/app_storage.dart';
import 'providers/theme_mode_provider.dart';
import 'providers/theme_name_provider.dart';

part 'app_themes_keys.dart';

@immutable
class AppThemes {
  static AppThemes? _instance;

  final Ref ref;
  final AppStorage appStorage;

  const AppThemes._({
    required this.ref,
    required this.appStorage,
  });

  static AppThemes getInstance({
    required Ref ref,
    required AppStorage appStorage,
  }) {
    _instance ??= AppThemes._(
      ref: ref,
      appStorage: appStorage,
    );

    return _instance!;
  }

  Future<void> changeTheme({
    required String themeName,
    required ThemeMode themeMode,
  }) async {
    await appStorage.write(
      key: AppStorageKeys.themeName,
      value: themeName,
    );

    final isDarkModeCondition = themeMode == ThemeMode.dark;
    final isDarkModeValue = themeMode == ThemeMode.system
        ? null
        : isDarkModeCondition;

    await appStorage.write(
      key: AppStorageKeys.isDarkMode,
      value: isDarkModeValue,
    );

    final themeNameProviderNotifier = ref.read(
      themeNameProvider.notifier,
    );
    themeNameProviderNotifier.state = themeName;

    final themeModeProviderNotifier = ref.read(
      themeModeProvider.notifier,
    );
    themeModeProviderNotifier.state = themeMode;
  }
}
