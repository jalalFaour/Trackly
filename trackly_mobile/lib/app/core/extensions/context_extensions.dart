import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../global_widgets/app_button_widget.dart';
import '../../global_widgets/app_text_widget.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  AppLocalizations get localizations => AppLocalizations.of(this)!;

  Future<bool?> showAlertDialog({
    String? title,
    required String message,
    String? confirmMessage,
    bool withCancel = false,
  }) {
    return showDialog<bool>(
      context: this,
      builder: (BuildContext context) {
        return AlertDialog(
          title: title == null ? null : AppTextWidget(text: title),
          content: AppTextWidget(text: message),
          actions: [
            // Cancel
            if (withCancel)
              AppButtonWidget(
                text: context.localizations.cancel,
                onPressed: () {
                  context.pop(false);
                },
              ),

            // Confirm
            AppButtonWidget(
              text: confirmMessage ?? context.localizations.ok,
              onPressed: () {
                context.pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
