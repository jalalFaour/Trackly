import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/login_controller_provider.dart';

TextEditingController useLoginPassword({
  required WidgetRef ref,
  String? initialText,
}) => use(
  _LoginPasswordHook(
    ref: ref,
    initialText: initialText,
  ),
);

class _LoginPasswordHook extends Hook<TextEditingController> {
  final WidgetRef ref;
  final String? initialText;

  const _LoginPasswordHook({
    required this.ref,
    required this.initialText,
  });

  @override
  _LoginPasswordHookState createState() => _LoginPasswordHookState();
}

class _LoginPasswordHookState extends HookState<TextEditingController, _LoginPasswordHook> {
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
    loginController.updatePassword(
      value: textEditingController.text,
    );
  }
}
