import 'package:flutter/material.dart';
import 'package:trackly/app/core/ui/base_ui_state.dart';

@immutable
class LoginUiState extends BaseUiState {
  final String phone;
  final String password;
  final bool isLoading;

  const LoginUiState({
    required this.phone,
    required this.password,
    required this.isLoading,
    super.errorMessage,
  });

  factory LoginUiState.defaultObj() => LoginUiState(
    phone: '',
    password: '',
    isLoading: false,
  );

  @override
  LoginUiState copyWith({
    String? phone,
    String? password,
    bool? isLoading,
    bool clearErrorMessage = false,
    String? errorMessage,
  }) => LoginUiState(
    phone: phone ?? this.phone,
    password: password ?? this.password,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
  );
}
