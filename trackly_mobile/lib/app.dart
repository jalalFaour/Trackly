import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/core/themes/providers/theme_data_provider.dart';
import 'app/core/themes/providers/theme_mode_provider.dart';
import 'app/routing/app_router_provider.dart';
import 'l10n/app_localizations.dart';
import 'l10n/providers/locale_provider.dart';

class App extends ConsumerWidget {
  const App({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final goRouter = ref.read(
      goRouterProvider,
    );

    final themeMode = ref.watch(
      themeModeProvider,
    );

    final locale = ref.watch(
      localeProvider,
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      // Routing
      routerConfig: goRouter,

      // Themes
      theme: ref.read(
        themeDataProvider(
          ThemeMode.light,
        ),
      ),
      darkTheme: ref.read(
        themeDataProvider(
          ThemeMode.dark,
        ),
      ),
      themeMode: themeMode,
      // themeMode: ThemeMode.light,

      // Localization
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
    );
  }
}
