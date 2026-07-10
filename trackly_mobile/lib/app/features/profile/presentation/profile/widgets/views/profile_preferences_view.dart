import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../../core/extensions/context_extensions.dart';
import '../../../../../../core/values/app_colors.dart';
import '../../../../../../core/values/app_dimensions.dart';

class ProfilePreferencesView extends StatelessWidget {
  final ThemeMode themeMode;
  final bool isArabic;
  final Future<void> Function(ThemeMode themeMode) onThemeModeChanged;
  final Future<void> Function(bool value) onLanguageChanged;

  const ProfilePreferencesView({
    super.key,
    required this.themeMode,
    required this.isArabic,
    required this.onThemeModeChanged,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme
            .surfaceContainerLow, // Soft, modern container background
        borderRadius: BorderRadius.circular(AppDimensions.radius20),
        boxShadow: AppColors.boxShadowSM,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Theme Mode Section
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingOrMargin16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.palette_outlined,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                    const Gap(AppDimensions.paddingOrMargin08),
                    Text(
                      context.localizations.themeMode,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Gap(AppDimensions.paddingOrMargin12),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.system,
                        label: Text(context.localizations.system),
                        icon: const Icon(Icons.brightness_auto_outlined),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.light,
                        label: Text(context.localizations.light),
                        icon: const Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        label: Text(context.localizations.dark),
                        icon: const Icon(Icons.dark_mode_outlined),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (Set<ThemeMode> newSelection) {
                      onThemeModeChanged(newSelection.first);
                    },
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      side: BorderSide(color: colorScheme.outlineVariant),
                      selectedBackgroundColor: colorScheme.primaryContainer,
                      selectedForegroundColor: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(color: colorScheme.outlineVariant, height: 1),

          // Language Section
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingOrMargin16,
              vertical: AppDimensions.paddingOrMargin04,
            ),
            leading: Icon(
              Icons.translate,
              color: colorScheme.primary,
              size: 22,
            ),
            title: Text(
              context.localizations.language,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: PopupMenuButton<bool>(
              initialValue: isArabic,
              onSelected: onLanguageChanged,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: false,
                  child: Text(context.localizations.english),
                ),
                PopupMenuItem(
                  value: true,
                  child: Text(context.localizations.arabic),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isArabic
                          ? context.localizations.arabic
                          : context.localizations.english,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: colorScheme.primary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
