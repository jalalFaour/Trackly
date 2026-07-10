import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/storage/app_storage_provider.dart';
import '../global_pages/error/app_error_page.dart';
import 'app_router_routes.dart';

final goRouterProvider = Provider<GoRouter>(
  (ref) {
    final appStorage = ref.read(appStorageProvider);

    return GoRouter(
      routes: AppRouterRoutes.routes,
      initialLocation: AppRouterEnum.splash.path,
      initialExtra: null,
      errorBuilder:
          (
            BuildContext context,
            GoRouterState state,
          ) {
            return const AppErrorPage(
              message: 'No route match',
            );
          },
      debugLogDiagnostics: true,
      redirect:
          (
            BuildContext context,
            GoRouterState state,
          ) {
            // final isLoggedIn = appStorage.read<bool>(
            //   key: AppStorageKeys.isLoggedIn,
            //   defaultValue: false,
            // );
            // final role = UserRoleEnum.fromValue(
            //   appStorage.read<String>(
            //     key: AppStorageKeys.role,
            //     defaultValue: UserRoleEnum.user.name,
            //   ),
            // );
            // final location = state.matchedLocation;

            // if (!isLoggedIn) {
            //   if (location == AppRouterEnum.navRoot.path ||
            //       location.startsWith('${AppRouterEnum.nav.path}/')) {
            //     return AppRouterEnum.login.path;
            //   }

            //   return null;
            // }

            // if (location == AppRouterEnum.login.path ||
            //     location == AppRouterEnum.register.path ||
            //     location == AppRouterEnum.splash.path ||
            //     location == AppRouterEnum.navRoot.path) {
            //   return '${AppRouterEnum.nav.path}/${role.defaultNavSubPage}';
            // }

            // if (location.startsWith('${AppRouterEnum.nav.path}/')) {
            //   final subPage = state.pathParameters[AppRouterKeys.subPage];
            //   if (subPage == null || !role.navSubPages.contains(subPage)) {
            //     return '${AppRouterEnum.nav.path}/${role.defaultNavSubPage}';
            //   }
            // }

            return null;
          },
      redirectLimit: 5,
    );
  },
);
