import 'package:trackly/app/core/network/api_caller_provider.dart';
import 'package:trackly/app/core/ui/base_controller.dart';
import 'package:trackly/app/core/values/constants/app_urls.dart';
import 'package:trackly/app/features/auth/providers/auth_service_provider.dart';

import '../../domain/entities/transaction.dart';
import 'ui/wallet_ui_state.dart';

class WalletController extends BaseController<WalletUiState> {
  @override
  WalletUiState onInit() => WalletUiState.defaultObj();

  void afterViewReady() {
    getBalance();
  }

  void updateAmount({
    required String value,
  }) {
    if (value == state.amount.toString()) {
      return;
    }
    print('Updating amount to: $value');
    state = state.copyWith(
      amount: int.tryParse(value) ?? 0,
    );
  }

  Future<void> addTransaction({
    required int amount,
  }) async {
    print(amount);
    final apiCaller = ref.read(
      apiCallerProvider,
    );

    final authService = ref.read(
      authServiceProvider,
    );

    await apiCaller.post(
      token: await authService.accessToken,
      url: AppUrls.walletAddBalance,
      data: {
        'amount': amount,
      },
      onSuccess: (dynamic data) async {
        getBalance();
      },
      onError: (String? key, String errorMessage) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: errorMessage.isEmpty
              ? 'حدث خطأ أثناء جلب بيانات المحفظة'
              : errorMessage,
        );
      },
    );
  }

  Future<void> getBalance() async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
    );

    final apiCaller = ref.read(
      apiCallerProvider,
    );

    final authService = ref.read(
      authServiceProvider,
    );

    await apiCaller.get(
      token: await authService.accessToken,
      url: AppUrls.walletBalance,
      onSuccess: (dynamic rawPayload) async {
        // 1. Safeguard & Parse the base wrapper response structure
        final jsonMap = rawPayload as Map<String, dynamic>;
        final isSuccess = jsonMap['isSuccess'] as bool? ?? false;

        if (!isSuccess) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'تعذر قراءة بيانات المحفظة',
          );
          return;
        }

        // 2. Extract nested data property maps
        final dataBlock = jsonMap['data'] as Map<String, dynamic>? ?? {};
        final balance = (dataBlock['balance'] ?? 0) as int;
        final transactionsRaw = dataBlock['transactions'] as List? ?? [];

        // 3. Map the list using your updated Transaction.fromJson factory
        final parsedTransactions = transactionsRaw
            .map(
              (element) =>
                  Transaction.fromJson(element as Map<String, dynamic>),
            )
            .toList();

        // 4. Update state cleanly
        state = state.copyWith(
          isLoading: false,
          transactions: parsedTransactions,
          balance: balance,
          clearErrorMessage: true,
        );
      },
      onError: (String? key, String errorMessage) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: errorMessage.isEmpty
              ? 'حدث خطأ أثناء جلب بيانات المحفظة'
              : errorMessage,
        );
      },
    );
  }
}
