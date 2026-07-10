import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/register_controller_provider.dart';

TextEditingController useRegisterNickName({
  required WidgetRef ref,
  String? initialText,
}) => use(
  _RegisterNickNameHook(
    ref: ref,
    initialText: initialText,
  ),
);

class _RegisterNickNameHook extends Hook<TextEditingController> {
  final WidgetRef ref;
  final String? initialText;

  const _RegisterNickNameHook({
    required this.ref,
    required this.initialText,
  });

  @override
  _RegisterNickNameHookState createState() => _RegisterNickNameHookState();
}

class _RegisterNickNameHookState extends HookState<TextEditingController, _RegisterNickNameHook> {
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
    final registerController = hook.ref.read(
      registerControllerProvider.notifier,
    );
    registerController.updateName(
      value: textEditingController.text,
    );
  }
}
