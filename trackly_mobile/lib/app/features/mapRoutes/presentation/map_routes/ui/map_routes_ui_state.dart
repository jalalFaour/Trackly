import 'package:flutter/material.dart';
import 'package:trackly/app/core/ui/base_ui_state.dart';

import '../../../domain/entities/map_route.dart';

@immutable
class MapRoutesUiState extends BaseUiState {
  final List<MapRoute> mapRoutes;
  final bool isLoading;

  const MapRoutesUiState({
    required this.mapRoutes,
    required this.isLoading,
    super.errorMessage,
  });

  factory MapRoutesUiState.defaultObj() => MapRoutesUiState(
    mapRoutes: [],
    isLoading: false,
  );

  @override
  MapRoutesUiState copyWith({
    List<MapRoute>? mapRoutes,
    bool? isLoading,
    bool clearErrorMessage = false,
    String? errorMessage,
  }) => MapRoutesUiState(
    mapRoutes: mapRoutes ?? this.mapRoutes,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
  );
}
