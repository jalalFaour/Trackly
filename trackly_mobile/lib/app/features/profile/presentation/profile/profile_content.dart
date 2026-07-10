import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/themes/providers/theme_mode_provider.dart';
import '../../../../core/values/app_dimensions.dart';
import '../../../../../l10n/providers/locale_provider.dart';
import 'providers/profile_controller_provider.dart';
import 'widgets/views/profile_header_view.dart';
import 'widgets/views/profile_preferences_view.dart';

class ProfileContent extends ConsumerWidget {
  const ProfileContent({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state = ref.watch(profileControllerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    final isArabic = locale.languageCode == 'ar';
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final user = state.user;

    return RefreshIndicator(
      onRefresh: () {
        return ref.read(profileControllerProvider.notifier).loadProfile();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppDimensions.paddingOrMargin16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    constraints.maxHeight -
                    (AppDimensions.paddingOrMargin16 * 2),
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileHeaderView(user: user),
                    const Gap(AppDimensions.paddingOrMargin24),
                    ProfilePreferencesView(
                      themeMode: themeMode,
                      isArabic: isArabic,
                      onThemeModeChanged: (ThemeMode mode) {
                        return ref
                            .read(profileControllerProvider.notifier)
                            .changeThemeMode(themeMode: mode);
                      },
                      onLanguageChanged: (bool value) {
                        return ref
                            .read(profileControllerProvider.notifier)
                            .toggleLanguage(isArabic: value);
                      },
                    ),
                    const Gap(AppDimensions.paddingOrMargin24),
                    const Spacer(),
                    // Modernized Destructive Action Tile Container
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radius20,
                        ),
                      ),
                      child: ListTile(
                        onTap: () => ref
                            .read(profileControllerProvider.notifier)
                            .logout(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radius20,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingOrMargin16,
                          vertical: AppDimensions.paddingOrMargin04,
                        ),
                        leading: Icon(
                          Icons.logout_rounded,
                          color: colorScheme.error,
                          size: 22,
                        ),
                        title: Text(
                          context.localizations.logout,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: colorScheme.error.withOpacity(0.6),
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
