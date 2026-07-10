import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/core/storage/app_storage_provider.dart';
import '../app_localization.dart';

final appLocalizationProvider = Provider<AppLocalization>(
  (ref) {
    final appStorage = ref.read(
      appStorageProvider,
    );

    return AppLocalization.getInstance(
      ref: ref,
      appStorage: appStorage,
    );
  },
);
