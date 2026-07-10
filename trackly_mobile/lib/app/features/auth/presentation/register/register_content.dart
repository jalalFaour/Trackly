import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'widgets/views/register_phone_view.dart';
import 'widgets/views/register_name_view.dart';
import 'widgets/views/register_password_view.dart';
import 'widgets/views/register_submit_view.dart';

class RegisterContent extends HookConsumerWidget {
  const RegisterContent({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // NickName
          RegisterNameView(),

          // Phone
          RegisterPhoneView(),

          // Password
          RegisterPasswordView(),

          // Submit / Progress
          RegisterSubmitView(),
        ],
      ),
    );
  }
}
