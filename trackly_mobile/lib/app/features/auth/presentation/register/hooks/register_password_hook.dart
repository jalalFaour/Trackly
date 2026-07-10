import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/register_controller_provider.dart';

TextEditingController useRegisterPassword({
  required WidgetRef ref,
  String? initialText,
}) => use(
  _RegisterPasswordHook(
    ref: ref,
    initialText: initialText,
  ),
);

class _RegisterPasswordHook extends Hook<TextEditingController> {
  final WidgetRef ref;
  final String? initialText;

  const _RegisterPasswordHook({
    required this.ref,
    required this.initialText,
  });

  @override
  _RegisterPasswordHookState createState() => _RegisterPasswordHookState();
}

class _RegisterPasswordHookState extends HookState<TextEditingController, _RegisterPasswordHook> {
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
    registerController.updatePassword(
      value: textEditingController.text,
    );
  }
}
