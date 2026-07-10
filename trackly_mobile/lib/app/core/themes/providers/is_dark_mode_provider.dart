import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'theme_mode_provider.dart';

final isDarkModeProvider = StateProvider<bool>(
  (ref) {
    final themeMode = ref.watch(
      themeModeProvider,
    );

    return themeMode == ThemeMode.dark;
  },
);
