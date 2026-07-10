import 'package:flutter/material.dart';

@immutable
class SplashUiState {
  final bool isLoading;

  const SplashUiState({
    required this.isLoading,
  });

  factory SplashUiState.defaultObj() => SplashUiState(
    isLoading: false,
  );

  SplashUiState copyWith({
    bool? isLoading,
  }) => SplashUiState(
    isLoading: isLoading ?? this.isLoading,
  );
}
