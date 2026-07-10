import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackly/app/core/extensions/context_extensions.dart';

import 'providers/tracking_controller_provider.dart';
import 'widgets/views/tracking_filters_view.dart';
import 'widgets/views/tracking_map_view.dart';

/// Holds the GlobalKey pointing at the live [TrackingMapView] state so the
/// Scaffold's FABs (in TrackingPage) can drive `recenterOnUser` on the map.
final GlobalKey<State<TrackingMapView>> trackingMapViewKey =
    GlobalKey<State<TrackingMapView>>();

class TrackingContent extends ConsumerWidget {
  const TrackingContent({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final uiState = ref.watch(trackingControllerProvider);
    final theme = context.theme;

    if (uiState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: [
        // Map (background layer). The key exposes its State to the page
        // so the recenter FAB can animate the camera.
        TrackingMapView(key: trackingMapViewKey),

        // Filters (top layer)
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: TrackingFiltersView(),
          ),
        ),
      ],
    );
  }
}
