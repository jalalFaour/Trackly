import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app_localizations.dart';
import 'locale_provider.dart';

final appLocalizationsProvider = Provider<AppLocalizations>(
  (ref) {
    final locale = ref.watch(
      localeProvider,
    );

    return lookupAppLocalizations(
      locale,
    );
  },
);
