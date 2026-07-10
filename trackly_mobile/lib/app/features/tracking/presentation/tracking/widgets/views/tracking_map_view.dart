import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:trackly/app/core/values/app_colors.dart';
import 'package:trackly/app/core/values/app_dimensions.dart';
import 'package:trackly/app/global_widgets/app_text_widget.dart';

import '../../providers/tracking_controller_provider.dart';
import 'tracking_map_view_stop_marker.dart';

class _StopEtaDialog extends StatelessWidget {
  final String stopName;
  final Future<Map<String, dynamic>?> estimateFuture;

  const _StopEtaDialog({
    required this.stopName,
    required this.estimateFuture,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppTextWidget(
        text: stopName,
        fontSize: AppDimensions.fontSize18,
        fontWeight: FontWeight.bold,
      ),
      content: FutureBuilder<Map<String, dynamic>?>(
        future: estimateFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              width: 240,
              height: 120,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return AppTextWidget(
              text: 'Unable to estimate arrival time right now.',
              fontSize: AppDimensions.fontSize14,
              color: Colors.red,
            );
          }

          final eta = snapshot.data!;
          final status = eta['status']?.toString() ?? 'upcoming';
          final etaText = eta['etaText']?.toString() ?? 'Unknown';
          final remainingDistance =
              eta['remainingDistanceKm']?.toString() ?? '0';
          final speed = eta['speedKmh']?.toString() ?? '20';
          final isPassed = status == 'passed';

          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPassed ? Icons.schedule_outlined : Icons.timer_outlined,
                    color: isPassed ? Colors.red : AppColors.primary,
                    size: 42,
                  ),
                ),
                Gap(AppDimensions.width20),
                AppTextWidget(
                  text: isPassed
                      ? 'Bus already passed this stop'
                      : 'Estimated arrival',
                  fontSize: AppDimensions.fontSize16,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: 10),
                AppTextWidget(
                  text: isPassed ? etaText : '$etaText at a fixed $speed km/h',
                  fontSize: AppDimensions.fontSize14,
                  color: isPassed ? Colors.red : Colors.black87,
                ),
                const SizedBox(height: 8),
                AppTextWidget(
                  text: 'Remaining route distance: $remainingDistance km',
                  fontSize: AppDimensions.fontSize12,
                  color: Colors.black54,
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class TrackingMapView extends StatefulHookConsumerWidget {
  const TrackingMapView({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TrackingMapViewState();
}

class _TrackingMapViewState extends ConsumerState<TrackingMapView> {
  static const double aleppoLat = 36.2021;
  static const double aleppoLng = 37.1343;

  final MapController mapController = MapController();

  void recenterOnUser(LatLng target) {
    mapController.move(target, 16.0);
  }

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(trackingControllerProvider);
    final selectedRoute = uiState.selectedRoute;

    final polylinePoints = selectedRoute == null
        ? <LatLng>[]
        : (selectedRoute.path.coordinates.isNotEmpty
              ? selectedRoute.path.coordinates
                    .map((coord) => LatLng(coord[1], coord[0]))
                    .toList()
              : <LatLng>[]);

    final busLocation = uiState.nearestBusLocation;
    final userLocation = uiState.userLocation;

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: userLocation ?? const LatLng(aleppoLat, aleppoLng),
        initialZoom: 13.0,
        minZoom: 5.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.trackly.app',
        ),
        if (polylinePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: polylinePoints,
                strokeWidth: 4.0,
                color: Colors.blueAccent,
                borderColor: Colors.white,
                borderStrokeWidth: 1.0,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            if (selectedRoute != null)
              ...selectedRoute.stops!.asMap().entries.map((entry) {
                final stopIndex = entry.key;
                final stop = entry.value;
                final stopCoordinates = stop.location.coordinates;

                return Marker(
                  point: LatLng(
                    stopCoordinates.length >= 2 ? stopCoordinates[1] : 0.0,
                    stopCoordinates.length >= 2 ? stopCoordinates[0] : 0.0,
                  ),
                  width: 20,
                  height: 20,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      final nameToShow = stop.name.isNotEmpty
                          ? stop.name
                          : stop.order.toString();

                      if (busLocation == null) {
                        showDialog<void>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: AppTextWidget(
                                text: nameToShow,
                                fontSize: AppDimensions.fontSize18,
                                fontWeight: FontWeight.bold,
                              ),
                              content: AppTextWidget(
                                text: 'Bus location is not available yet.',
                                fontSize: AppDimensions.fontSize14,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }

                      showDialog<void>(
                        context: context,
                        builder: (context) {
                          return _StopEtaDialog(
                            stopName: nameToShow,
                            estimateFuture: ref.trackingController
                                .getStopEtaForStop(
                                  routeId: selectedRoute.id,
                                  stopIndex: stopIndex,
                                  busLatitude: busLocation.latitude,
                                  busLongitude: busLocation.longitude,
                                ),
                          );
                        },
                      );
                    },
                    child: StopMarker(
                      isFirst: stop.order == 0,
                    ),
                  ),
                );
              }),
            if (busLocation != null)
              Marker(
                point: busLocation,
                width: 48,
                height: 48,
                child: AnimatedScale(
                  scale: uiState.isStreamingNearestBus ? 1.0 : 0.96,
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.14),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.directions_bus_filled_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                ),
              ),
            if (userLocation != null)
              Marker(
                point: userLocation,
                width: 46,
                height: 46,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.35),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.person_pin_circle_rounded,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
