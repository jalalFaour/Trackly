import 'package:trackly/app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trackly/app/global_widgets/app_button_widget.dart';

import '../../providers/login_controller_provider.dart';

class LoginSubmitView extends HookConsumerWidget {
  const LoginSubmitView({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final isLoading = ref.watch(
      loginControllerProvider.select(
        (value) => value.isLoading,
      ),
    );

    // Progress
    if (isLoading) {
      return CircularProgressIndicator();
    }

    // Submit
    return AppButtonWidget(
      text: context.localizations.login,
      backgroundColor: context.theme.filledButtonTheme.style!.backgroundColor!
          .resolve({})!,
      textColor: context.theme.filledButtonTheme.style!.foregroundColor!
          .resolve({})!,
      onPressed: () {
        final controller = ref.read(
          loginControllerProvider.notifier,
        );
        controller.submit(
          onFailure:
              (
                String message,
              ) {
                context.showAlertDialog(
                  message: message,
                );
              },
        );
      },
    );
  }
}
