import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackly/app/core/extensions/context_extensions.dart';

import '../../core/ui/base_controller.dart';
import '../../core/ui/base_ui_state.dart';

class AppBasePage<StateT extends BaseUiState> extends ConsumerStatefulWidget {
  final dynamic baseControllerProvider;
  final Widget content;

  const AppBasePage({
    super.key,
    this.baseControllerProvider,
    required this.content,
  });

  @override
  ConsumerState<AppBasePage<StateT>> createState() =>
      _AppBasePageState<StateT>();
}

class _AppBasePageState<StateT extends BaseUiState>
    extends ConsumerState<AppBasePage<StateT>> {
  bool _isErrorDialogVisible = false;

  @override
  void initState() {
    super.initState();

    if (widget.baseControllerProvider != null) {
      ref.listenManual<StateT>(widget.baseControllerProvider!, (
        StateT? previous,
        StateT next,
      ) async {
        final nextErrorMessage = next.errorMessage;
        if (nextErrorMessage == null ||
            nextErrorMessage == previous?.errorMessage ||
            _isErrorDialogVisible) {
          return;
        }

        if (!mounted) {
          return;
        }

        _isErrorDialogVisible = true;
        try {
          await context.showAlertDialog(message: nextErrorMessage);
        } finally {
          if (mounted) {
            _isErrorDialogVisible = false;
          }

          final baseController =
              ref.read(widget.baseControllerProvider.notifier)
                  as BaseController<StateT>;

          baseController.updateErrorMessage(clearErrorMessage: true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: widget.content);
  }
}
