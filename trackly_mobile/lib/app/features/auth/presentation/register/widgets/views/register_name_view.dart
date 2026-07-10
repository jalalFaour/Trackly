import 'package:trackly/app/core/extensions/context_extensions.dart';
import 'package:trackly/app/core/values/app_dimensions.dart';
import 'package:trackly/app/global_widgets/app_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../hooks/register_nick_name_hook.dart';

class RegisterNameView extends HookConsumerWidget {
  const RegisterNameView({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final nickNameTextEditingController = useRegisterNickName(
      ref: ref,
      initialText: null,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingOrMargin20,
        vertical: AppDimensions.paddingOrMargin10,
      ),
      child: AppTextFieldWidget(
        textEditingController: nickNameTextEditingController,
        hintText: context.localizations.name,
      ),
    );
  }
}
