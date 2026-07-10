import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:trackly/app/core/extensions/context_extensions.dart';
import 'package:trackly/app/core/values/app_dimensions.dart';
import 'package:trackly/app/global_widgets/app_text_widget.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/enums/transaction_type_enum.dart';
import 'providers/wallet_controller_provider.dart';

class WalletContent extends ConsumerWidget {
  const WalletContent({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final uiState = ref.watch(walletControllerProvider);
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    if (uiState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(
              walletControllerProvider.notifier,
            )
            .getBalance();
      },

      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(
          AppDimensions.paddingOrMargin16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modern Balance Card Header
            _buildBalanceCard(
              context,
              uiState.balance,
            ),
            const Gap(
              AppDimensions.paddingOrMargin24,
            ),

            // Section Title
            Text(
              context.localizations.transactions,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const Gap(
              AppDimensions.paddingOrMargin12,
            ),

            uiState.transactions.isEmpty
                ? _buildModernEmptyState(context)
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: uiState.transactions.length,
                    separatorBuilder: (context, index) =>
                        const Gap(AppDimensions.paddingOrMargin08),
                    itemBuilder: (context, index) {
                      final transaction = uiState.transactions[index];
                      return _buildModernTransactionCard(context, transaction);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    int balance,
  ) {
    final colorScheme = context.theme.colorScheme;
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.all(
        AppDimensions.paddingOrMargin24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          AppDimensions.radius24,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.localizations.balance,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(
            AppDimensions.paddingOrMargin08,
          ),
          Text(
            '$balance SYP', // Customize currency format as needed
            style: theme.textTheme.headlineLarge?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernEmptyState(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 40.0,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 72,
              color: context.theme.colorScheme.onSurface.withOpacity(0.2),
            ),
            const Gap(AppDimensions.paddingOrMargin16),
            AppTextWidget(
              text: context.localizations.noTransactionsFound,
              style: context.theme.textTheme.titleMedium?.copyWith(
                color: context.theme.colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTransactionCard(
    BuildContext context,
    Transaction transaction,
  ) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final isCredit = transaction.type == TransactionType.credit;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(
          AppDimensions.radius16,
        ),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radius16,
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: isCredit
              ? Colors.green.withOpacity(0.12)
              : colorScheme.errorContainer.withOpacity(0.5),
          child: Icon(
            isCredit
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            color: isCredit ? Colors.green : colorScheme.error,
            size: AppDimensions.width20,
          ),
        ),
        title: AppTextWidget(
          text: transaction.bussId ?? transaction.type.localize(context),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: AppTextWidget(
          text: DateFormat(
            'MMM dd, yyyy • hh:mm a',
          ).format(transaction.timestamp),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: AppTextWidget(
          text: '${isCredit ? "+" : "-"} ${transaction.amount} SYP',
          style: theme.textTheme.titleMedium?.copyWith(
            color: isCredit ? Colors.green : colorScheme.error,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
