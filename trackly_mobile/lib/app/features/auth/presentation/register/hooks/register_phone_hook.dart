import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/register_controller_provider.dart';

TextEditingController useRegisterPhone({
  required WidgetRef ref,
  String? initialText,
}) => use(
  _RegisterEmailHook(
    ref: ref,
    initialText: initialText,
  ),
);

class _RegisterEmailHook extends Hook<TextEditingController> {
  final WidgetRef ref;
  final String? initialText;

  const _RegisterEmailHook({
    required this.ref,
    required this.initialText,
  });

  @override
  _RegisterEmailHookState createState() => _RegisterEmailHookState();
}

class _RegisterEmailHookState
    extends HookState<TextEditingController, _RegisterEmailHook> {
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
    registerController.updatePhone(
      value: textEditingController.text,
    );
  }
}
