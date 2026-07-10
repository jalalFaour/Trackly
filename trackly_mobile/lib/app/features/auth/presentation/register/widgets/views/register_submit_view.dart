import 'package:trackly/app/core/extensions/context_extensions.dart';
import 'package:trackly/app/global_widgets/app_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/register_controller_provider.dart';

class RegisterSubmitView extends HookConsumerWidget {
  const RegisterSubmitView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(
      registerControllerProvider.select((value) => value.isLoading),
    );

    // Progress
    if (isLoading) {
      return CircularProgressIndicator();
    }

    // Submit
    return AppButtonWidget(
      text: context.localizations.signup,
      backgroundColor: context.theme.filledButtonTheme.style!.backgroundColor!
          .resolve({})!,
      onPressed: () {
        final controller = ref.read(registerControllerProvider.notifier);
        controller.submit(
          onFailure: (String message) {
            context.showAlertDialog(message: message);
          },
        );
      },
    );
  }
}
