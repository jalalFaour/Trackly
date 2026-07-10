import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:trackly/app/core/extensions/context_extensions.dart';
import 'package:trackly/app/core/values/app_assets.dart';
import 'package:trackly/app/core/values/app_colors.dart';
import 'package:trackly/app/core/values/app_dimensions.dart';
import 'package:trackly/app/global_widgets/app_button_widget.dart';
import 'package:trackly/app/global_widgets/app_image_widget.dart';
import 'package:trackly/app/routing/app_router_routes.dart';

import 'widgets/views/login_email_view.dart';
import 'widgets/views/login_password_view.dart';
import 'widgets/views/login_submit_view.dart';

class LoginContent extends ConsumerWidget {
  const LoginContent({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final isDarkMode = context.theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        children: [
          // logo
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingOrMargin20,
            ),
            child: AppImageWidget(
              path: isDarkMode
                  ? AppAssets.splashScreenLogoDark
                  : AppAssets.splashScreenLogoLight,
            ),
          ),

          // Email
          const LoginPhoneView(),

          // Password
          const LoginPasswordView(),

          Gap(
            AppDimensions.paddingOrMargin20,
          ),

          // Submit / Progress
          const LoginSubmitView(),

          Gap(
            AppDimensions.paddingOrMargin20,
          ),

          // if you don't have an account, sign up
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.localizations.ifYouDontHaveAnAccount,
              ),
              AppButtonWidget(
                backgroundColor: AppColors.transparent,
                textColor: context
                    .theme
                    .filledButtonTheme
                    .style!
                    .backgroundColor!
                    .resolve({})!,
                onPressed: () {
                  context.pushNamed(
                    AppRouterEnum.register.name,
                  );
                },
                text: context.localizations.signup,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
