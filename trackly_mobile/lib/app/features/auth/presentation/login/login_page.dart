import 'package:trackly/app/features/auth/presentation/login/login_content.dart';
import 'package:trackly/app/features/auth/presentation/login/providers/login_controller_provider.dart';
import 'package:trackly/app/global_pages/error/app_base_page.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return AppBasePage(
      baseControllerProvider: loginControllerProvider,
      content: Scaffold(
        body: LoginContent(),
      ),
    );
  }
}
