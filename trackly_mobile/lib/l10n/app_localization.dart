import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app/core/storage/app_storage.dart';
import 'enums/app_localization_enum.dart';
import 'providers/locale_provider.dart';

@immutable
class AppLocalization {
  static AppLocalization? _instance;

  final Ref ref;
  final AppStorage appStorage;

  const AppLocalization._({
    required this.ref,
    required this.appStorage,
  });

  static AppLocalization getInstance({
    required Ref ref,
    required AppStorage appStorage,
  }) {
    _instance ??= AppLocalization._(
      ref: ref,
      appStorage: appStorage,
    );

    return _instance!;
  }

  Future<void> changeLocale({
    required String localeKey,
  }) async {
    await appStorage.write(
      key: AppStorageKeys.localeKey,
      value: localeKey,
    );

    final lang = localeKey
        .split(
          '_',
        )
        .first;

    final isRtlCondition = AppLocalizationEnum.rtlLanguages.contains(
      lang,
    );
    await appStorage.write(
      key: AppStorageKeys.isRTL,
      value: isRtlCondition,
    );

    final locale = getLocale(
      localeKey: localeKey,
    );

    final localeProviderNotifier = ref.read(
      localeProvider.notifier,
    );
    localeProviderNotifier.state = locale;
  }

  Locale getLocale({
    required String localeKey,
  }) {
    final localeKeySplit = localeKey.split(
      '_',
    );

    final languageCode = localeKeySplit.first;
    final countryCode = localeKeySplit.last;

    return Locale.fromSubtags(
      scriptCode: '_',
      languageCode: languageCode,
      countryCode: countryCode,
    );
  }
}
