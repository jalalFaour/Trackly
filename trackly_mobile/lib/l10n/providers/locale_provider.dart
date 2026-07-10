import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../app/core/storage/app_storage.dart';
import '../../app/core/storage/app_storage_provider.dart';
import '../enums/app_localization_enum.dart';
import 'app_localization_provider.dart';

final localeProvider = StateProvider<Locale>((ref) {
  final appStorage = ref.read(appStorageProvider);

  final localeKey = appStorage.read<String>(
    key: AppStorageKeys.localeKey,
    defaultValue: AppLocalizationEnum.english.localeKey,
  );

  final appLocalization = ref.read(appLocalizationProvider);

  return appLocalization.getLocale(localeKey: localeKey);
});
