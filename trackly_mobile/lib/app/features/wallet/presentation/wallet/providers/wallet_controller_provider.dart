import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ui/wallet_ui_state.dart';
import '../wallet_controller.dart';


final walletControllerProvider =
    NotifierProvider<WalletController, WalletUiState>(
      () {
        return WalletController();
      },
    );

extension walletControllerProviderWidgetRefExtension on WidgetRef {
  WalletController get walletController => read(
    walletControllerProvider.notifier,
  );
}

extension walletControllerProviderRefExtension on Ref {
  WalletController get walletController => read(
    walletControllerProvider.notifier,
  );
}
