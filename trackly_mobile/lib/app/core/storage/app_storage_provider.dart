import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app_storage.dart';

final appStorageProvider = Provider.autoDispose<AppStorage>(
  (ref) {
    return AppStorage.getInstance();
  },
);
