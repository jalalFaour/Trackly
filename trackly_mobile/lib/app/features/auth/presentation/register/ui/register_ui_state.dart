import 'package:flutter/material.dart';
import 'package:trackly/app/core/ui/base_ui_state.dart';


@immutable
class RegisterUiState extends BaseUiState {
  final String name;
  final String phone;
  final String password;
  final bool isLoading;

  const RegisterUiState({
    required this.name,
    required this.phone,
    required this.password,
    required this.isLoading,
    String? errorMessage,
  });

  factory RegisterUiState.defaultObj() => RegisterUiState(
    name: '',
    phone: '',
    password: '',
    isLoading: false,
  );

  @override
  RegisterUiState copyWith({
    String? name,
    String? phone,
    String? password,
    bool? isLoading,
    bool clearErrorMessage = false,
    String? errorMessage,
  }) => RegisterUiState(
    name: name ?? this.name,
    phone: phone ?? this.phone,
    password: password ?? this.password,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
  );
}
