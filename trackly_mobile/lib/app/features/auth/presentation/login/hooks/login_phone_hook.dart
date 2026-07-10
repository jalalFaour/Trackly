import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/login_controller_provider.dart';

TextEditingController useLoginPhone({
  required WidgetRef ref,
  String? initialText,
}) => use(
  _LoginPhoneHook(
    ref: ref,
    initialText: initialText,
  ),
);

class _LoginPhoneHook extends Hook<TextEditingController> {
  final WidgetRef ref;
  final String? initialText;

  const _LoginPhoneHook({
    required this.ref,
    required this.initialText,
  });

  @override
  _LoginPhoneHookState createState() => _LoginPhoneHookState();
}

class _LoginPhoneHookState
    extends HookState<TextEditingController, _LoginPhoneHook> {
  late final TextEditingController textEditingController;

  @override
  void initHook() {
    super.initHook();

    textEditingController = TextEditingController(
      text: hook.initialText,
    );
    textEditingController.addListener(
      listener,
    );
  }

  @override
  TextEditingController build(
    BuildContext context,
  ) {
    return textEditingController;
  }

  @override
  void dispose() {
    textEditingController.removeListener(
      listener,
    );
    textEditingController.dispose();

    super.dispose();
  }

  void listener() {
    final loginController = hook.ref.read(
      loginControllerProvider.notifier,
    );
    loginController.updatePhone(
      value: textEditingController.text,
    );
  }
}
