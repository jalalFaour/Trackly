import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/wallet_controller_provider.dart';

TextEditingController useWalletAmount({
  required WidgetRef ref,
  String? initialText,
}) => use(
  _WalletAmountHook(
    ref: ref,
    initialText: initialText,
  ),
);

class _WalletAmountHook extends Hook<TextEditingController> {
  final WidgetRef ref;
  final String? initialText;

  const _WalletAmountHook({
    required this.ref,
    required this.initialText,
  });

  @override
  _WalletAmountHookState createState() => _WalletAmountHookState();
}

class _WalletAmountHookState
    extends HookState<TextEditingController, _WalletAmountHook> {
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
    final walletController = hook.ref.read(
      walletControllerProvider.notifier,
    );
    walletController.updateAmount(
      value: textEditingController.text,
    );
  }
}
