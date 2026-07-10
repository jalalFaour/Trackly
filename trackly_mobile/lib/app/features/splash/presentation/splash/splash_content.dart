import 'package:trackly/app/core/extensions/context_extensions.dart';
import 'package:trackly/app/core/values/app_assets.dart';
import 'package:trackly/app/core/values/app_dimensions.dart';
import 'package:trackly/app/global_widgets/app_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/splash_controller_provider.dart';

class SplashContent extends ConsumerWidget {
  const SplashContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(
      splashControllerProvider.select((value) => value.isLoading),
    );

    final isDarkMode = context.theme.brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(
              AppDimensions.paddingOrMargin20,
            ),
            child: AppImageWidget(
              path: isDarkMode
                  ? AppAssets.splashScreenLogoDark
                  : AppAssets.splashScreenLogoLight,
            ),
          ),
        ),
      ),
    );
  }
}
