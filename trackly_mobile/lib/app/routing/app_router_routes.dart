import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/storage/app_storage.dart';
import '../features/auth/presentation/login/login_page.dart';
import '../features/auth/presentation/register/register_page.dart';
import '../features/nav/presentation/nav_page.dart';

import '../features/splash/presentation/splash/splash_page.dart';
import '../global_pages/error/app_error_page.dart';

part 'app_router_enum.dart';
part 'app_router_keys.dart';

abstract class AppRouterRoutes {
  static final routes = [
    // Root
    GoRoute(
      name: AppRouterEnum.splash.name,
      path: AppRouterEnum.splash.path,
      builder:
          (
            BuildContext context,
            GoRouterState state,
          ) {
            return const SplashPage();
          },
    ),

    ///region Auth

    // Register
    GoRoute(
      name: AppRouterEnum.register.name,
      path: AppRouterEnum.register.path,
      builder:
          (
            BuildContext context,
            GoRouterState state,
          ) {
            return const RegisterPage();
          },
    ),

    // Login
    GoRoute(
      name: AppRouterEnum.login.name,
      path: AppRouterEnum.login.path,
      builder:
          (
            BuildContext context,
            GoRouterState state,
          ) {
            return const LoginPage();
          },
    ),

    ///endregion Auth

    ///region Todos

    // Todos
    // GoRoute(
    //   name: AppRouterEnum.todos.name,
    //   path: AppRouterEnum.todos.path,
    //   builder:
    //       (
    //         BuildContext context,
    //         GoRouterState state,
    //       ) {
    //         return const TodosPage();
    //       },
    // ),

    // TodoUpsert
    // GoRoute(
    //   name: AppRouterEnum.todoUpsert.name,
    //   path: AppRouterEnum.todoUpsert.path,
    //   builder:
    //       (
    //         BuildContext context,
    //         GoRouterState state,
    //       ) {
    //         return const TodoUpsertPage();
    //       },
    // ),

    ///endregion Todos

    // Nav
    GoRoute(
      name: AppRouterEnum.navRoot.name,
      path: AppRouterEnum.navRoot.path,
      builder:
          (
            BuildContext context,
            GoRouterState state,
          ) {
            final appStorage = AppStorage.getInstance();

            return NavPage(
              subPage: '',
            );
          },
    ),

    GoRoute(
      name: AppRouterEnum.nav.name,
      path: AppRouterEnum.nav.path,
      builder:
          (
            BuildContext context,
            GoRouterState state,
          ) {
            final pathParameters = state.pathParameters;
            final queryParameters = state.uri.queryParameters;

            final subPage = pathParameters[AppRouterKeys.subPage];
            if (subPage == null) {
              return const AppErrorPage(
                message: 'Nav page must be with subPage',
              );
            }

            final routeId = queryParameters[AppRouterKeys.routeId];

            return NavPage(
              subPage: subPage,
              routeId: routeId,
            );
          },
    ),

    // // Donation details
    // GoRoute(
    //   name: AppRouterEnum.donationDetails.name,
    //   path: AppRouterEnum.donationDetails.path,
    //   builder:
    //       (
    //         BuildContext context,
    //         GoRouterState state,
    //       ) {
    //         final pathParameters = state.pathParameters;

    //         final donationId = pathParameters[AppRouterKeys.donationId];

    //         if (donationId == null) {
    //           return const AppErrorPage(
    //             message: 'Donation details page must be with donation id',
    //           );
    //         }

    //         return DonationDetailsPage(
    //           donationId: donationId,
    //         );
    //       },
    // ),

    // // Requests
    // GoRoute(
    //   name: AppRouterEnum.requests.name,
    //   path: AppRouterEnum.requests.path,
    //   builder:
    //       (
    //         BuildContext context,
    //         GoRouterState state,
    //       ) {
    //         return const MyRequestsPage();
    //       },
    // ),

    ///region Products

    // // Products
    // GoRoute(
    //   name: AppRouterEnum.products.name,
    //   path: AppRouterEnum.products.path,
    //   builder: (
    //     BuildContext context,
    //     GoRouterState state,
    //   ) {
    //     return const ProductsPage();
    //   },
    //   routes: [
    //     // Product Details
    //     GoRoute(
    //       name: AppRouterEnum.productDetails.name,
    //       path: AppRouterEnum.productDetails.path,
    //       builder: (
    //         BuildContext context,
    //         GoRouterState state,
    //       ) {
    //         return const ProductDetailsPage();
    //       },
    //       routes: [
    //         // Product Bills
    //         GoRoute(
    //           name: AppRouterEnum.productBills.name,
    //           path: AppRouterEnum.productBills.path,
    //           builder: (
    //             BuildContext context,
    //             GoRouterState state,
    //           ) {
    //             return const ProductBillsPage();
    //           },
    //         ),
    //       ],
    //     ),
    //   ],
    // ),

    ///endregion Products

    ///region Movies

    // // Movies
    // GoRoute(
    //   name: AppRouterEnum.movies.name,
    //   path: AppRouterEnum.movies.path,
    //   builder:
    //       (
    //         BuildContext context,
    //         GoRouterState state,
    //       ) {
    //         return const MoviesPage();
    //       },
    // ),
    //
    // // Movie Details
    // GoRoute(
    //   name: AppRouterEnum.movieDetails.name,
    //   path: AppRouterEnum.movieDetails.path,
    //   builder:
    //       (
    //         BuildContext context,
    //         GoRouterState state,
    //       ) {
    //         return const MovieDetailsPage();
    //       },
    // ),
    //
    // // Movie Pay
    // GoRoute(
    //   path: AppRouterEnum.moviePay.path,
    //   name: AppRouterEnum.moviePay.name,
    //   builder:
    //       (
    //         BuildContext context,
    //         GoRouterState state,
    //       ) {
    //         return const MoviePayPage();
    //       },
    // ),

    ///endregion Movies
  ];
}
