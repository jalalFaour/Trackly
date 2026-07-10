import 'package:trackly/app/core/extensions/context_extensions.dart';
import 'package:trackly/app/core/values/app_dimensions.dart';
import 'package:trackly/app/global_widgets/app_icon_widget.dart';
import 'package:trackly/app/global_widgets/app_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../hooks/login_password_hook.dart';

class LoginPasswordView extends HookConsumerWidget {
  const LoginPasswordView({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final passwordTextEditingController = useLoginPassword(
      ref: ref,
      initialText: null,
    );

    final isPasswordShownState = useState<bool>(false);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingOrMargin20,
        vertical: AppDimensions.paddingOrMargin10,
      ),
      child: AppTextFieldWidget(
        textEditingController: passwordTextEditingController,
        hintText: context.localizations.password,
        obscureText: !isPasswordShownState.value,
        suffix: AppIconWidget(
          iconData: isPasswordShownState.value
              ? Icons.visibility
              : Icons.visibility_off,
          onTap: () {
            isPasswordShownState.value = !isPasswordShownState.value;
          },
        ),
      ),
    );
  }
}
