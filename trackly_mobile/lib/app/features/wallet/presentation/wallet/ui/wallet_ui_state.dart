import 'package:flutter/material.dart';
import 'package:trackly/app/core/ui/base_ui_state.dart';

import '../../../domain/entities/transaction.dart';

@immutable
class WalletUiState extends BaseUiState {
  final List<Transaction> transactions;
  final int balance;
  final int amount;
  final bool isLoading;

  const WalletUiState({
    required this.transactions,
    this.balance = 0,
    this.amount = 0,
    required this.isLoading,
    super.errorMessage,
  });

  factory WalletUiState.defaultObj() => WalletUiState(
    transactions: [],
    balance: 0,
    amount: 0,
    isLoading: false,
  );

  @override
  WalletUiState copyWith({
    List<Transaction>? transactions,
    int? balance,
    int? amount,
    bool? isLoading,
    bool clearErrorMessage = false,
    String? errorMessage,
  }) => WalletUiState(
    transactions: transactions ?? this.transactions,
    balance: balance ?? this.balance,
    amount: amount ?? this.amount,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
  );
}
