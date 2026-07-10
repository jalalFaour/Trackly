import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trackly/app/core/extensions/context_extensions.dart';
import 'package:trackly/app/core/values/app_dimensions.dart';
import 'package:trackly/app/global_widgets/app_list_tile_widget.dart';
import 'package:trackly/app/global_widgets/app_text_widget.dart';
import 'package:trackly/app/routing/app_router_routes.dart';

import '../../domain/entities/map_route.dart';
import 'providers/map_routes_controller_provider.dart';

class MapRoutesContent extends ConsumerWidget {
  const MapRoutesContent({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final uiState = ref.watch(
      mapRoutesControllerProvider,
    );

    return SingleChildScrollView(
      child: uiState.mapRoutes.isEmpty
          ? _buildModernEmptyState(context)
          : Padding(
              padding: EdgeInsets.all(
                AppDimensions.paddingOrMargin12,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: uiState.mapRoutes.length,
                itemBuilder: (context, index) {
                  final route = uiState.mapRoutes[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: _buildModernRouteCard(
                      context,
                      route,
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildModernEmptyState(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.route_outlined,
              size: AppDimensions.width110,
              color: context.theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            SizedBox(
              height: AppDimensions.paddingOrMargin12,
            ),
            AppTextWidget(
              text: 'No routes found.',
              style: context.theme.textTheme.titleMedium?.copyWith(
                color: context.theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernRouteCard(
    BuildContext context,
    MapRoute route,
  ) {
    final theme = context.theme;

    return InkWell(
      onTap: () {
        context.goNamed(
          AppRouterEnum.nav.name,
          pathParameters: {
            AppRouterKeys.subPage: 'donations',
          },
          queryParameters: {
            AppRouterKeys.routeId: route.id,
          },
        );
      },
      // BoxDecoration(
      //   gradient: LinearGradient(
      //     colors: [
      //       colorScheme.primary,
      //       colorScheme.primary.withOpacity(0.8),
      //     ],
      //     begin: Alignment.topLeft,
      //     end: Alignment.bottomRight,
      //   ),
      //   borderRadius: BorderRadius.circular(
      //     AppDimensions.radius24,
      //   ),
      //   boxShadow: [
      //     BoxShadow(
      //       color: colorScheme.primary.withOpacity(0.3),
      //       blurRadius: 12,
      //       offset: const Offset(0, 6),
      //     ),
      //   ],
      // )
      borderRadius: BorderRadius.circular(AppDimensions.radius12),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(
            AppDimensions.radius24,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: AppListTileWidget(
          // Remove tileColor and shape from here since Container handles them
          title: AppTextWidget(
            text: route.routeName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.business_outlined,
                      size: 16,
                      color: theme.colorScheme.onPrimary.withOpacity(0.7),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: AppTextWidget(
                        text: route.companyName.isEmpty
                            ? 'Unknown Company'
                            : route.companyName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.straighten_outlined,
                      size: 16,
                      color: theme.colorScheme.onPrimary.withOpacity(0.7),
                    ),
                    const SizedBox(width: 6),
                    AppTextWidget(
                      text: '${route.routeLengthKm} km',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_outlined,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
