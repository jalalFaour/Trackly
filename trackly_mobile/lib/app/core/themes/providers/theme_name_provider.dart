import 'package:flutter_riverpod/legacy.dart';

import '../../storage/app_storage.dart';
import '../../storage/app_storage_provider.dart';
import '../app_themes.dart';

final themeNameProvider = StateProvider<String>(
  (ref) {
    final appStorage = ref.read(
      appStorageProvider,
    );

    final themeName = appStorage.read<String>(
      key: AppStorageKeys.themeName,
      defaultValue: AppThemesKeys.theme01,
    );

    return themeName;
  },
);
