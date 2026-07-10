import 'package:flutter/material.dart';

@immutable
class BaseUiState {
  final String? errorMessage;

  const BaseUiState({
    this.errorMessage,
  });

  const BaseUiState.defaultObj()
    : this(
        errorMessage: null,
      );

  BaseUiState copyWith({
    String? errorMessage,
    bool clearErrorMessage = false,
  }) => BaseUiState(
    errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
  );
}
