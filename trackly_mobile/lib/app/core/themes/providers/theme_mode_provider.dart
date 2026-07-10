import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../storage/app_storage.dart';
import '../../storage/app_storage_provider.dart';

final themeModeProvider = StateProvider<ThemeMode>(
  (ref) {
    final appStorage = ref.read(
      appStorageProvider,
    );

    final isDarkMode = appStorage.read<bool?>(
      key: AppStorageKeys.isDarkMode,
      defaultValue: null,
    );

    return isDarkMode == null
        ? ThemeMode.system
        : isDarkMode
        ? ThemeMode.dark
        : ThemeMode.light;
  },
);
