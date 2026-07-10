import 'package:flutter/material.dart';
import 'package:trackly/app/core/ui/base_ui_state.dart';
import 'package:trackly/app/features/mapRoutes/domain/entities/map_route.dart';
import 'package:latlong2/latlong.dart';

@immutable
class TrackingUiState extends BaseUiState {
  final List<MapRoute> mapRoutes;
  final int deductPrice;
  final bool isLoading;
  final String? selectedRouteId; // which filter chip is selected
  final MapRoute?
  selectedRoute; // the actual route to draw on map (null = nothing drawn)
  final LatLng? userLocation;
  final LatLng? nearestBusLocation;
  final String nearestBusLabel;
  final bool isStreamingNearestBus;

  const TrackingUiState({
    required this.mapRoutes,
    this.deductPrice = 0,
    this.isLoading = false,
    this.selectedRouteId,
    this.selectedRoute,
    this.userLocation,
    this.nearestBusLocation,
    this.nearestBusLabel = '',
    this.isStreamingNearestBus = false,
    super.errorMessage,
  });

  factory TrackingUiState.defaultObj() => TrackingUiState(
    mapRoutes: [],
    deductPrice: 0,
    selectedRouteId: null,
    selectedRoute: null,
    isLoading: false,
    userLocation: null,
    nearestBusLocation: null,
    nearestBusLabel: '',
    isStreamingNearestBus: false,
  );

  @override
  TrackingUiState copyWith({
    List<MapRoute>? mapRoutes,
    int? deductPrice,
    bool? isLoading,
    bool clearErrorMessage = false,
    String? errorMessage,
    String? selectedRouteId,
    bool clearSelectedRouteId = false,
    MapRoute? selectedRoute,
    bool clearSelectedRoute = false,
    LatLng? userLocation,
    bool clearUserLocation = false,
    LatLng? nearestBusLocation,
    bool clearNearestBusLocation = false,
    String? nearestBusLabel,
    bool? isStreamingNearestBus,
  }) => TrackingUiState(
    mapRoutes: mapRoutes ?? this.mapRoutes,
    deductPrice: deductPrice ?? this.deductPrice,
    isLoading: isLoading ?? this.isLoading,
    selectedRouteId: clearSelectedRouteId
        ? null
        : selectedRouteId ?? this.selectedRouteId,
    selectedRoute: clearSelectedRoute
        ? null
        : selectedRoute ?? this.selectedRoute,
    userLocation: clearUserLocation ? null : userLocation ?? this.userLocation,
    nearestBusLocation: clearNearestBusLocation
        ? null
        : nearestBusLocation ?? this.nearestBusLocation,
    nearestBusLabel: nearestBusLabel ?? this.nearestBusLabel,
    isStreamingNearestBus: isStreamingNearestBus ?? this.isStreamingNearestBus,
    errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
  );
}
