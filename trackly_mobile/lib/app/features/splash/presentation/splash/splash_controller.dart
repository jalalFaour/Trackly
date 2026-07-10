import 'package:trackly/app/core/extensions/ref_extensions.dart';
import 'package:trackly/app/core/storage/app_storage.dart';
import 'package:trackly/app/core/storage/app_storage_provider.dart';
import 'package:trackly/app/routing/app_router_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/splash_ui_state.dart';

class SplashController extends Notifier<SplashUiState> {
  @override
  SplashUiState build() {
    return SplashUiState.defaultObj();
  }

  Future<void> afterViewReady() async {
    state = state.copyWith(isLoading: true);

    await Future.delayed(const Duration(seconds: 3));

    state = state.copyWith(isLoading: false);

    final appStorage = ref.read(appStorageProvider);
    final isLoggedIn = appStorage.read<bool>(
      key: AppStorageKeys.isLoggedIn,
      defaultValue: false,
    );

    if (!isLoggedIn) {
      ref.goRouter.goNamed(AppRouterEnum.login.name);
      return;
    }

    ref.goRouter.goNamed(AppRouterEnum.navRoot.name);
  }
}
