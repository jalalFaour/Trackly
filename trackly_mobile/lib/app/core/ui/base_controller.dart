import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'base_ui_state.dart';

abstract class BaseController<T extends BaseUiState> extends Notifier<T> {
  @override
  T build() {
    ///region Lifecycle

    final state = onInit();

    ref.onResume(() {
      onResume();
    });

    ref.onCancel(() {
      onCancel();
    });

    ref.onDispose(() {
      onDispose();
    });

    ///endregion Lifecycle

    return state;
  }

  ///region Lifecycle

  T onInit();

  void onResume() {}

  void onCancel() {}

  var _isDisposed = false;

  bool get mounted => !_isDisposed;

  void onDispose() {
    _isDisposed = true;
  }

  ///endregion Lifecycle

  ///region Events

  void updateState({required T newState}) {
    state = newState;
  }

  void updateErrorMessage({String? value, bool clearErrorMessage = false}) {
    if (value == state.errorMessage && !clearErrorMessage) {
      return;
    }

    updateState(
      newState:
          state.copyWith(
                errorMessage: value,
                clearErrorMessage: clearErrorMessage,
              )
              as T,
    );
  }

  ///endregion Events

  ///region Private functions

  ///endregion Private functions
}
