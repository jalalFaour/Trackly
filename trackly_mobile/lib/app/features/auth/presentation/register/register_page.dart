import 'package:trackly/app/core/extensions/context_extensions.dart';
import 'package:trackly/app/features/auth/presentation/register/providers/register_controller_provider.dart';
import 'package:trackly/app/global_pages/error/app_base_page.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trackly/app/global_widgets/app_text_widget.dart';

import 'register_content.dart';

class RegisterPage extends HookConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return AppBasePage(
      baseControllerProvider: registerControllerProvider,
      content: Scaffold(
        appBar: AppBar(
          title: AppTextWidget(
            text: context.localizations.signup,
          ),
        ),
        body: RegisterContent(),
      ),
    );
  }
}
