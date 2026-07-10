import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:trackly/app/global_widgets/app_text_widget.dart';

import '../../../../../../core/extensions/context_extensions.dart';
import '../../../../../../core/values/app_colors.dart';
import '../../../../../../core/values/app_dimensions.dart';
import '../../../../domain/entities/profile_user.dart';

class ProfileHeaderView extends StatelessWidget {
  final ProfileUser user;

  const ProfileHeaderView({
    super.key,
    required this.user,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme = context.theme.colorScheme;
    final name = user.name.isEmpty ? 'User' : user.name;
    final nameInitial = name.trim().isNotEmpty
        ? name.trim().substring(0, 1).toUpperCase()
        : 'U';

    return Container(
      padding: const EdgeInsets.all(
        AppDimensions.paddingOrMargin16,
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
      child: Row(
        children: [
          CircleAvatar(
            radius: AppDimensions.radius30,
            backgroundColor: colorScheme.onPrimary.withValues(
              alpha: 0.16,
            ),
            child: AppTextWidget(
              text: nameInitial,
              style: context.theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Gap(
            AppDimensions.paddingOrMargin12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextWidget(
                  text: name,
                  style: context.theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(
                  AppDimensions.paddingOrMargin04,
                ),
                AppTextWidget(
                  text: user.phone,
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withValues(
                      alpha: 0.90,
                    ),
                  ),
                ),
                const Gap(
                  AppDimensions.paddingOrMargin08,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingOrMargin10,
                    vertical: AppDimensions.paddingOrMargin04,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary.withValues(
                      alpha: 0.14,
                    ),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radius28,
                    ),
                  ),
                  child: AppTextWidget(
                    text:
                        '${context.localizations.balance}: ${user.balance.toString()} SYP',
                    style: context.theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
