import 'package:flutter/material.dart';
import 'package:trackly/l10n/app_localizations.dart';

enum TransactionType {
  credit,
  debit;

  String localize(BuildContext context,) {
    final l = AppLocalizations.of(context,)!;
    return switch (this) {
      TransactionType.credit => l.credit,
      TransactionType.debit  => l.debit,
    };
  }
}
