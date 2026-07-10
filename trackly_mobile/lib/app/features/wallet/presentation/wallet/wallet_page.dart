import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trackly/app/core/extensions/context_extensions.dart';
import 'package:trackly/app/core/values/app_dimensions.dart';
import 'package:trackly/app/global_pages/error/app_base_page.dart';
import 'package:trackly/app/global_widgets/app_bar_widget.dart';
import 'package:trackly/app/global_widgets/app_icon_widget.dart';
import 'package:trackly/app/global_widgets/app_text_widget.dart';

import 'providers/wallet_controller_provider.dart';
import 'ui/wallet_ui_state.dart';
import 'wallet_content.dart';

class WalletPage extends StatefulHookConsumerWidget {
  const WalletPage({
    super.key,
  });
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        ref.walletController.afterViewReady();
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return AppBasePage<WalletUiState>(
      baseControllerProvider: walletControllerProvider,
      content: Scaffold(
        appBar: AppBarWidget(
          title: context.localizations.wallet,
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showModernTopUpDialog(context, ref),
          backgroundColor: context.theme.colorScheme.primary,
          foregroundColor: context.theme.colorScheme.onPrimary,
          elevation:
              0, // Flat design with slight tonal overlay is preferred in M3
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius16),
          ),
          child: const Icon(Icons.add_rounded, size: 28),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await ref.walletController.getBalance();
          },
          child: WalletContent(),
        ),
      ),
    );
  }

  void _showModernTopUpDialog(
    BuildContext context,
    WidgetRef ref,
  ) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    final amountTextEditingController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows sheet to push up above keyboard
      backgroundColor: colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radius24),
        ),
      ),
      builder: (context) {
        return Padding(
          // Handles safe spacing for onscreen keyboard
          padding: EdgeInsets.only(
            left: AppDimensions.paddingOrMargin20,
            right: AppDimensions.paddingOrMargin20,
            top: AppDimensions.paddingOrMargin16,
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                AppDimensions.paddingOrMargin20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handlebar accent line for visual affordance
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Gap(
                AppDimensions.paddingOrMargin20,
              ),

              AppTextWidget(
                text: context.localizations.walletTopUp,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(
                AppDimensions.paddingOrMargin20,
              ),

              // Card Number Input (Demo Only)
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const AppIconWidget(
                    iconData: Icons.credit_card_rounded,
                  ),
                  labelText: context.localizations.cardNumber,
                  hintText: '0000 0000 0000 0000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radius12,
                    ),
                  ),
                ),
              ),
              const Gap(
                AppDimensions.paddingOrMargin12,
              ),

              // Amount Input Field
              TextField(
                controller: amountTextEditingController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  prefixIcon: const AppIconWidget(
                    iconData: Icons.attach_money_rounded,
                  ),
                  labelText: context.localizations.amount,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radius12),
                  ),
                ),
              ),
              const Gap(
                AppDimensions.paddingOrMargin24,
              ),

              // Modern Action Buttons Block
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: colorScheme.onSurfaceVariant,
                      ),
                      child: const AppTextWidget(
                        text: 'Cancel',
                      ),
                    ),
                  ),
                  const Gap(AppDimensions.paddingOrMargin12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        // Trigger controller update state block
                        ref
                            .read(walletControllerProvider.notifier)
                            .addTransaction(
                              amount:
                                  double.tryParse(
                                    amountTextEditingController.text,
                                  )?.toInt() ??
                                  0,
                            );
                        Navigator.pop(context);
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radius12,
                          ),
                        ),
                      ),
                      child: AppTextWidget(
                        text: context.localizations.topUp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
