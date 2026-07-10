import 'package:flutter/material.dart';
import 'package:trackly/app/core/storage/app_storage_provider.dart';
import 'package:trackly/app/core/ui/base_controller.dart';
import 'package:trackly/app/routing/app_router_provider.dart';
import 'package:trackly/app/routing/app_router_routes.dart';

import '../../../../core/themes/providers/app_themes_provider.dart';
import '../../../../core/themes/providers/theme_name_provider.dart';
import '../../../../../l10n/enums/app_localization_enum.dart';
import '../../../../../l10n/providers/app_localization_provider.dart';
import '../../providers/profile_get_user_use_case_provider.dart';
import '../../domain/use_cases/profile_getUser_use_case.dart'
    as profile_get_user_use_case;
import 'ui/profile_ui_state.dart';

class ProfileController extends BaseController<ProfileUiState> {
  @override
  ProfileUiState onInit() => ProfileUiState.defaultObj();

  void afterViewReady() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
    );

    try {
      final profileGetUserUseCase = ref.read(
        profileGetUserUseCaseProvider,
      );

      profileGetUserUseCase
          .call(profile_get_user_use_case.Params())
          .then(
            (result) => result.fold(
              (failure) {
                state = state.copyWith(
                  isLoading: false,
                  errorMessage: failure.message,
                );
              },
              (dataState) {
                final user = dataState.data;
                print(user.toString());

                state = state.copyWith(
                  isLoading: false,
                  user: user,
                );
              },
            ),
          );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load profile data',
      );
    }
  }

  Future<void> changeThemeMode({
    required ThemeMode themeMode,
  }) async {
    final appThemes = ref.read(
      appThemesProvider,
    );
    final currentThemeName = ref.read(
      themeNameProvider,
    );

    await appThemes.changeTheme(
      themeName: currentThemeName,
      themeMode: themeMode,
    );
  }

  Future<void> toggleTheme({
    required bool isDarkMode,
  }) async {
    await changeThemeMode(
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }

  Future<void> toggleLanguage({
    required bool isArabic,
  }) async {
    final appLocalization = ref.read(
      appLocalizationProvider,
    );

    await appLocalization.changeLocale(
      localeKey: isArabic
          ? AppLocalizationEnum.arabic.localeKey
          : AppLocalizationEnum.english.localeKey,
    );
  }

  Future<void> logout() async {
    final appStorage = ref.read(
      appStorageProvider,
    );

    await appStorage.removeAll();

    final goRouter = ref.read(
      goRouterProvider,
    );

    goRouter.goNamed(
      AppRouterEnum.login.name,
    );

    state = state.copyWith(
      user: null,
    );
  }
}
