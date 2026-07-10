import 'package:dartz/dartz.dart';
import 'package:trackly/app/core/data/data_state.dart';
import 'package:trackly/app/core/error/failures.dart';
import 'package:trackly/app/core/extensions/ref_extensions.dart';
import 'package:trackly/app/core/extensions/string_extensions.dart';
import 'package:trackly/app/features/auth/domain/entities/auth_register_data.dart';
import 'package:trackly/app/features/auth/providers/auth_register_use_case_provider.dart';
import 'package:trackly/app/routing/app_router_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/use_cases/auth_register_use_case.dart'
    as auth_register_use_case;
import 'ui/register_ui_state.dart';

class RegisterController extends Notifier<RegisterUiState> {
  @override
  RegisterUiState build() {
    return RegisterUiState.defaultObj();
  }

  Future<void> afterViewReady() async {}

  void updateName({required String value}) {
    if (value == state.name) {
      return;
    }

    state = state.copyWith(name: value);
  }

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
    required void Function(
      String message,
    )
    onFailure,
  }) async {
    if (state.name.isNullOrEmpty ||
        state.phone.isNullOrEmpty ||
        state.password.isNullOrEmpty) {
      onFailure('Please fill all info');

      return;
    }

    state = state.copyWith(isLoading: true);

    final authRegisterUseCase = ref.read(authRegisterUseCaseProvider);
    final result = await authRegisterUseCase.call(
      auth_register_use_case.Params(
        data: AuthRegisterData(
          name: state.name,
          phone: state.phone,
          password: state.password,
        ),
      ),
    );
    await result.fold(
      (Failure failure) async {
        state = state.copyWith(isLoading: false);

        onFailure(failure.message);
      },
      (DataState<Unit> dataState) async {
        state = state.copyWith(isLoading: false);

        ref.goRouter.goNamed(AppRouterEnum.login.name);
      },
    );
  }

  ///endregion Events

  ///region Private Methods

  ///endregion Private Methods
}
