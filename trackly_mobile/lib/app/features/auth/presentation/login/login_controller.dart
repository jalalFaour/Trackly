import 'package:trackly/app/core/data/data_state.dart';
import 'package:trackly/app/core/error/failures.dart';
import 'package:trackly/app/core/extensions/ref_extensions.dart';
import 'package:trackly/app/core/extensions/string_extensions.dart';
import 'package:trackly/app/core/storage/app_storage.dart';
import 'package:trackly/app/core/storage/app_storage_provider.dart';
import 'package:trackly/app/features/auth/domain/entities/auth_login.dart';
import 'package:trackly/app/features/auth/domain/entities/auth_login_data.dart';
import 'package:trackly/app/routing/app_router_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trackly/app/features/auth/providers/auth_login_use_case_provider.dart';
import 'package:trackly/app/features/auth/providers/auth_service_provider.dart';

import '../../domain/use_cases/auth_login_use_case.dart' as auth_login_use_case;
import 'ui/login_ui_state.dart';

class LoginController extends Notifier<LoginUiState> {
  @override
  LoginUiState build() {
    return LoginUiState.defaultObj();
  }

  ///region Lifecycle

  ///endregion Lifecycle

  ///region Events

  void updatePhone({required String value}) {
    if (value == state.phone) {
      return;
    }

    state = state.copyWith(phone: value);
  }

  void updatePassword({required String value}) {
    if (value == state.password) {
      return;
    }

    state = state.copyWith(password: value);
  }

  Future<void> submit({
    required void Function(String message) onFailure,
  }) async {
    if (state.phone.isNullOrEmpty || state.password.isNullOrEmpty) {
      onFailure('Please fill all info');

      return;
    }

    state = state.copyWith(isLoading: true);

    final authLoginUseCase = ref.read(authLoginUseCaseProvider);
    final result = await authLoginUseCase.call(
      auth_login_use_case.Params(
        data: AuthLoginData(phone: state.phone, password: state.password),
      ),
    );
    await result.fold(
      (Failure failure) async {
        state = state.copyWith(isLoading: false);

        onFailure(failure.message);
      },
      (DataState<AuthLogin> dataState) async {
        state = state.copyWith(isLoading: false);

        final authService = ref.read(authServiceProvider);
        await authService.storeAuthData(authLogin: dataState.data);

        final appStorage = ref.read(appStorageProvider);
        await appStorage.write(key: AppStorageKeys.isLoggedIn, value: true);

        ref.goRouter.goNamed(AppRouterEnum.navRoot.name);
      },
    );
  }

  ///endregion Events

  ///region Private Methods

  ///endregion Private Methods
}
