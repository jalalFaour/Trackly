import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localization.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/providers/app_localization_provider.dart';
import '../../../l10n/providers/app_localizations_provider.dart';
import '../../routing/app_router_provider.dart';

extension RefExtensions on Ref {
  GoRouter get goRouter => read(goRouterProvider);

  AppLocalizations get localizations => read(appLocalizationsProvider);

  AppLocalization get appLocalization => read(appLocalizationProvider);
}

extension WidgetRefExtensions on WidgetRef {
  AppLocalizations get localizations => watch(appLocalizationsProvider);

  AppLocalization get appLocalization => read(appLocalizationProvider);
}
