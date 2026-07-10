import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trackly/app/core/values/app_colors.dart';
import 'package:trackly/app/core/values/app_dimensions.dart';
import 'package:trackly/app/features/tracking/presentation/tracking/providers/tracking_controller_provider.dart';
import 'package:trackly/app/global_widgets/app_text_widget.dart';
import 'package:trackly/app/routing/app_router_routes.dart';

import '../../../../../mapRoutes/domain/entities/map_route.dart';

class TrackingFiltersView extends ConsumerWidget {
  const TrackingFiltersView({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final uiState = ref.watch(trackingControllerProvider);
    final selectedRouteId = uiState.selectedRouteId;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      child: SizedBox(
        height: 30,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: uiState.mapRoutes.length,
          itemBuilder: (context, index) {
            final route = uiState.mapRoutes[index];
            final isSelected = selectedRouteId == route.id;

            return Padding(
              padding: const EdgeInsets.only(
                right: 8.0,
              ),
              child: _FilterChip(
                label: route.routeName,
                isSelected: isSelected,
                onTap: (willSelect) => _applyCategoryFilter(
                  ref: ref,
                  context: context,
                  route: willSelect ? route : null, // <-- pass full route
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _applyCategoryFilter({
    required WidgetRef ref,
    required BuildContext context,
    required MapRoute? route, // <-- changed from trackingId
  }) {
    final currentParams = GoRouterState.of(context).uri.queryParameters;
    final newParams = Map<String, String>.from(currentParams);

    if (route == null) {
      newParams.remove(AppRouterKeys.routeId);
      ref.trackingController.updateFilters(
        selectedRouteId: null,
        clearRoute: true, // <-- explicit clear
      );
    } else {
      newParams[AppRouterKeys.routeId] = route.id;
      ref.trackingController.updateFilters(
        selectedRouteId: route.id,
        routeToDraw: route, // <-- set the polyline source
      );
    }

    context.goNamed(
      AppRouterEnum.nav.name,
      pathParameters: {'subPage': 'donations'},
      queryParameters: newParams,
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return FilterChip(
      label: AppTextWidget(
        text: label,
        fontSize: AppDimensions.fontSize12,
      ),
      selected: isSelected,
      onSelected: onTap,
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }
}
