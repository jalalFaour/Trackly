import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../storage/app_storage_provider.dart';
import '../app_themes.dart';

final appThemesProvider = Provider<AppThemes>(
  (ref) {
    final appStorage = ref.read(
      appStorageProvider,
    );

    return AppThemes.getInstance(
      ref: ref,
      appStorage: appStorage,
    );
  },
);
