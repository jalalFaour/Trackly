import 'package:flutter/material.dart';
import 'package:trackly/app/core/ui/base_ui_state.dart';

import '../../../domain/entities/profile_user.dart';

@immutable
class ProfileUiState extends BaseUiState {
  final bool isLoading;
  final ProfileUser user;

  const ProfileUiState({
    required this.isLoading,
    required this.user,
    super.errorMessage,
  });

  factory ProfileUiState.defaultObj() => const ProfileUiState(
    isLoading: true,
    user: ProfileUser(
      id: '',
      name: '',
      phone: '',
      balance: 0,
    ),
  );

  @override
  ProfileUiState copyWith({
    bool? isLoading,
    ProfileUser? user,
    bool clearUser = false,
    bool clearErrorMessage = false,
    String? errorMessage,
  }) => ProfileUiState(
    isLoading: isLoading ?? this.isLoading,
    user: user ?? this.user,
    errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
  );
}
