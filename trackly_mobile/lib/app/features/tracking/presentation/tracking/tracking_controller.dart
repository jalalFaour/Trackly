import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:trackly/app/core/network/api_caller_provider.dart';
import 'package:trackly/app/core/network_response/network_response.dart';
import 'package:trackly/app/core/ui/base_controller.dart';
import 'package:trackly/app/core/values/constants/app_urls.dart';
import 'package:trackly/app/core/utils/app_log_utils.dart';
import 'package:trackly/app/features/auth/providers/auth_service_provider.dart';
import 'package:trackly/app/features/mapRoutes/domain/entities/map_route.dart';

import 'ui/tracking_ui_state.dart';

class TrackingController extends BaseController<TrackingUiState> {
  final Location _location = Location();
  CancelToken? _nearestBusCancelToken;
  StreamSubscription<LocationData>? _locationSubscription;
  LatLng? _lastStreamLocation;
  String? _lastStreamRouteId;

  @override
  TrackingUiState onInit() => TrackingUiState.defaultObj();

  void afterViewReady({String? selectedRouteId}) {
    _bootstrapLocation();
    getroutes(selectedRouteId: selectedRouteId);
    getPriceOfTicket();
  }

  @override
  void onDispose() {
    _stopNearestBusStream();
    _locationSubscription?.cancel();
    _locationSubscription = null;
    super.onDispose();
  }

  Future<void> updateFilters({
    String? selectedRouteId,
    MapRoute? routeToDraw,
    bool clearRoute = false,
  }) async {
    final previousRouteId = state.selectedRouteId;
    final isDeselecting =
        clearRoute || selectedRouteId == null || selectedRouteId.isEmpty;

    state = state.copyWith(
      selectedRouteId: selectedRouteId,
      clearSelectedRouteId: isDeselecting,
      selectedRoute: routeToDraw,
      clearSelectedRoute: isDeselecting,
      isLoading: !isDeselecting,
    );

    if (isDeselecting) {
      _stopNearestBusStream();
      state = state.copyWith(
        clearNearestBusLocation: true,
        nearestBusLabel: '',
        isStreamingNearestBus: false,
      );
      return;
    }

    if (previousRouteId != selectedRouteId) {
      await _startNearestBusStream(routeId: selectedRouteId);
    }
  }

  Future<void> getroutes({
    String? selectedRouteId,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
    );

    final apiCaller = ref.read(apiCallerProvider);
    final authService = ref.read(authServiceProvider);

    await apiCaller.get(
      token: await authService.accessToken,
      url: AppUrls.routes,
      onSuccess: (dynamic data) async {
        final response = NetworkResponse.fromJson<MapRoute>(
          data as Map<String, dynamic>,
          MapRoute.fromJson,
        );

        if (!response.isSuccess) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'تعذر قراءة بيانات التبرعات',
          );
          return;
        }

        final routes = response.dataList ?? <MapRoute>[];
        final routeIdToSelect = selectedRouteId ?? state.selectedRouteId;
        final selectedRoute = _findRouteById(routes, routeIdToSelect);
        final previousSelectedRouteId = state.selectedRouteId;

        state = state.copyWith(
          isLoading: false,
          mapRoutes: routes,
          selectedRouteId: selectedRoute?.id,
          clearSelectedRouteId:
              routeIdToSelect != null && selectedRoute == null,
          selectedRoute: selectedRoute,
          clearSelectedRoute: routeIdToSelect != null && selectedRoute == null,
          clearErrorMessage: true,
        );

        if (selectedRoute != null &&
            previousSelectedRouteId != selectedRoute.id) {
          await _startNearestBusStream(routeId: selectedRoute.id);
        }
      },
      onError: (String? key, String errorMessage) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: errorMessage.isEmpty
              ? 'حدث خطأ أثناء جلب بيانات التبرعات'
              : errorMessage,
        );
      },
    );
  }

  MapRoute? _findRouteById(
    List<MapRoute> routes,
    String? routeId,
  ) {
    if (routeId == null || routeId.isEmpty) {
      return null;
    }

    for (final route in routes) {
      if (route.id == routeId) {
        return route;
      }
    }

    return null;
  }

  Future<void> getPriceOfTicket() async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
    );

    final apiCaller = ref.read(apiCallerProvider);
    final authService = ref.read(authServiceProvider);

    await apiCaller.get(
      token: await authService.accessToken,
      url: AppUrls.walletDeductBalance,
      onSuccess: (dynamic data) async {
        final json = data as Map<String, dynamic>;
        final deductPrice = json['data']['priceInPounds'] as int?;

        state = state.copyWith(
          isLoading: false,
          deductPrice: deductPrice,
          clearErrorMessage: true,
        );
      },
      onError: (String? key, String errorMessage) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: errorMessage.isEmpty
              ? 'حدث خطأ أثناء جلب بيانات التبرعات'
              : errorMessage,
        );
      },
    );
  }

  Future<void> payForTheBus({
    required String busId,
    required Function onSuccess,
  }) async {
    final apiCaller = ref.read(apiCallerProvider);
    final authService = ref.read(authServiceProvider);

    await apiCaller.post(
      token: await authService.accessToken,
      url: AppUrls.walletDeduct,
      data: {
        'busId': busId,
      },
      onSuccess: (dynamic data) async {
        onSuccess();
      },
      onError: (String? key, String errorMessage) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: errorMessage.isEmpty
              ? 'حدث خطأ أثناء جلب بيانات المحفظة'
              : errorMessage,
        );
      },
    );
  }

  Future<Map<String, dynamic>?> getStopEtaForStop({
    required String routeId,
    required int stopIndex,
    required double busLatitude,
    required double busLongitude,
  }) async {
    final apiCaller = ref.read(apiCallerProvider);
    final authService = ref.read(authServiceProvider);

    Map<String, dynamic>? etaData;

    await apiCaller.post(
      token: await authService.accessToken,
      url: AppUrls.routeStopEta,
      data: {
        'routeId': routeId,
        'stopIndex': stopIndex,
        'busLatitude': busLatitude,
        'busLongitude': busLongitude,
      },
      onSuccess: (dynamic data) async {
        final response = NetworkResponse.fromJson<Map<String, dynamic>>(
          data as Map<String, dynamic>,
        );

        if (!response.isSuccess) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: response.message.isEmpty
                ? 'تعذر حساب الوقت المتوقع للوصول'
                : response.message,
          );
          return;
        }

        etaData = response.data;
      },
      onError: (String? key, String errorMessage) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: errorMessage.isEmpty
              ? 'تعذر حساب الوقت المتوقع للوصول'
              : errorMessage,
        );
      },
    );

    return etaData;
  }

  Future<void> _bootstrapLocation() async {
    try {
      AppLogUtils.debugLog(
        message: '[tracking] bootstrapping location permission',
      );

      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        AppLogUtils.debugLog(
          message: '[tracking] location service disabled, requesting enable',
        );
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          AppLogUtils.debugLog(
            message: '[tracking] location service still disabled',
          );
          return;
        }
      }

      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        AppLogUtils.debugLog(
          message:
              '[tracking] location permission denied, requesting permission',
        );
        permission = await _location.requestPermission();
      }

      if (permission != PermissionStatus.granted &&
          permission != PermissionStatus.grantedLimited) {
        AppLogUtils.debugLog(
          message: '[tracking] location permission not granted: $permission',
        );
        return;
      }

      final locationData = await _location.getLocation();
      AppLogUtils.debugLog(
        message:
            '[tracking] initial location lat=${locationData.latitude} lng=${locationData.longitude}',
      );
      _updateUserLocation(locationData.latitude, locationData.longitude);

      await _locationSubscription?.cancel();
      _locationSubscription = _location.onLocationChanged.listen((
        locationData,
      ) {
        AppLogUtils.debugLog(
          message:
              '[tracking] location updated lat=${locationData.latitude} lng=${locationData.longitude}',
        );
        _updateUserLocation(locationData.latitude, locationData.longitude);
      });
    } catch (_) {}
  }

  void _updateUserLocation(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) {
      return;
    }

    final nextLocation = LatLng(latitude, longitude);
    final previousLocation = state.userLocation;

    state = state.copyWith(
      userLocation: nextLocation,
      clearErrorMessage: true,
    );

    final selectedRouteId = state.selectedRouteId;
    if (selectedRouteId?.isNotEmpty == true &&
        _shouldRestartStreamForLocation(nextLocation, previousLocation)) {
      AppLogUtils.debugLog(
        message:
            '[tracking] user location changed, restarting nearest bus stream for route=$selectedRouteId',
      );
      _startNearestBusStream(routeId: selectedRouteId!);
    }
  }

  Future<void> _startNearestBusStream({required String routeId}) async {
    final userLocation = state.userLocation;
    if (userLocation == null) {
      AppLogUtils.debugLog(
        message:
            '[tracking] skipping stream start because user location is null',
      );
      return;
    }

    _stopNearestBusStream();

    final apiCaller = ref.read(apiCallerProvider);
    final authService = ref.read(authServiceProvider);
    _nearestBusCancelToken = CancelToken();
    _lastStreamLocation = userLocation;
    _lastStreamRouteId = routeId;

    AppLogUtils.debugLog(
      message:
          '[tracking] starting nearest bus stream routeId=$routeId lat=${userLocation.latitude} lng=${userLocation.longitude} url=${AppUrls.nearestBusStream}',
    );

    state = state.copyWith(
      isStreamingNearestBus: true,
      nearestBusLabel: '',
      clearErrorMessage: true,
    );

    try {
      final response = await apiCaller.dio.post<ResponseBody>(
        AppUrls.nearestBusStream,
        data: {
          'routeId': routeId,
          'latitude': userLocation.latitude,
          'longitude': userLocation.longitude,
        },
        options: Options(
          headers: {
            'Accept': 'text/event-stream',
            'Authorization': 'Bearer ${await authService.accessToken}',
          },
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(seconds: 30),
        ),
        cancelToken: _nearestBusCancelToken,
      );

      AppLogUtils.debugLog(
        message: '[tracking] stream connected status=${response.statusCode}',
      );

      await _consumeNearestBusStream(response.data!.stream);
    } on DioException catch (err) {
      if (err.type == DioExceptionType.cancel) {
        AppLogUtils.debugLog(
          message: '[tracking] nearest bus stream cancelled intentionally',
        );
        return;
      }

      AppLogUtils.errorLog(
        message:
            '[tracking] nearest bus stream request failed type=${err.type} message=${err.message} response=${err.response?.statusCode} data=${err.response?.data}',
        exception: err,
        stackTrace: err.stackTrace,
      );
      if (!mounted) return;
      state = state.copyWith(
        isStreamingNearestBus: false,
        errorMessage: _normalizeStreamErrorMessage(err),
      );
    }
  }

  Future<void> _consumeNearestBusStream(Stream<List<int>> byteStream) async {
    final buffer = StringBuffer();
    String? currentEvent;
    AppLogUtils.debugLog(message: '[tracking] entering SSE stream loop');

    await for (final chunk in byteStream) {
      if (!mounted) return;

      AppLogUtils.debugLog(
        message: '[tracking] SSE chunk received size=${chunk.length}',
      );

      buffer.write(utf8.decode(chunk, allowMalformed: true));
      final content = buffer.toString();
      final lines = content.split('\n');

      buffer.clear();
      if (!content.endsWith('\n')) {
        buffer.write(lines.removeLast());
      }

      for (final rawLine in lines) {
        final line = rawLine.trimRight();
        if (line.isEmpty) {
          currentEvent = null;
          continue;
        }

        if (line.startsWith('event:')) {
          currentEvent = line.substring(6).trim();
          AppLogUtils.debugLog(message: '[tracking] SSE event=$currentEvent');
          continue;
        }

        if (!line.startsWith('data:')) {
          continue;
        }

        final dataText = line.substring(5).trim();
        if (currentEvent == 'error') {
          final dynamic decoded = jsonDecode(dataText);
          final message = decoded is Map<String, dynamic>
              ? decoded['message']?.toString() ??
                    'تعذر الاتصال بخدمة تتبع الحافلة الأقرب'
              : 'تعذر الاتصال بخدمة تتبع الحافلة الأقرب';

          AppLogUtils.errorLog(
            message: '[tracking] SSE error payload=$dataText',
          );

          state = state.copyWith(
            isStreamingNearestBus: false,
            errorMessage: message,
          );
          _stopNearestBusStream();
          return;
        }

        if (currentEvent == 'done') {
          _stopNearestBusStream();
          return;
        }

        if (currentEvent != 'nearest-bus') {
          continue;
        }

        final dynamic decoded = jsonDecode(dataText);
        if (decoded is! Map<String, dynamic>) {
          AppLogUtils.debugLog(
            message: '[tracking] SSE payload was not a map: $dataText',
          );
          continue;
        }

        final nearestBus = decoded['nearestBus'];
        if (nearestBus == null || nearestBus is! Map) {
          AppLogUtils.debugLog(
            message: '[tracking] no nearest bus returned in payload',
          );
          state = state.copyWith(
            clearNearestBusLocation: true,
            nearestBusLabel: 'No nearby bus found',
            isStreamingNearestBus: true,
          );
          continue;
        }

        final lastLocation = nearestBus['lastLocation'];
        if (lastLocation is Map) {
          final coordinates =
              (lastLocation['coordinates'] as List? ?? const []);
          if (coordinates.length >= 2) {
            final lng = (coordinates[0] as num).toDouble();
            final lat = (coordinates[1] as num).toDouble();

            AppLogUtils.debugLog(
              message:
                  '[tracking] nearest bus update label=${nearestBus['busNumber'] ?? nearestBus['deviceId']} lat=$lat lng=$lng',
            );

            state = state.copyWith(
              nearestBusLocation: LatLng(lat, lng),
              nearestBusLabel:
                  nearestBus['busNumber']?.toString().isNotEmpty == true
                  ? nearestBus['busNumber'].toString()
                  : nearestBus['deviceId']?.toString() ?? 'Nearest bus',
              isStreamingNearestBus: true,
            );
          }
        }
      }
    }

    if (mounted) {
      state = state.copyWith(isStreamingNearestBus: false);
    }
  }

  void _stopNearestBusStream() {
    AppLogUtils.debugLog(message: '[tracking] stopping nearest bus stream');
    _nearestBusCancelToken?.cancel('route changed');
    _nearestBusCancelToken = null;
    state = state.copyWith(isStreamingNearestBus: false);
  }

  bool _shouldRestartStreamForLocation(
    LatLng nextLocation,
    LatLng? previousLocation,
  ) {
    final routeId = state.selectedRouteId;
    if (routeId?.isEmpty != false) {
      return false;
    }

    if (_lastStreamRouteId != routeId) {
      return true;
    }

    if (_lastStreamLocation == null || previousLocation == null) {
      return true;
    }

    final movedMeters = const Distance().as(
      LengthUnit.Meter,
      _lastStreamLocation!,
      nextLocation,
    );

    return movedMeters >= 50;
  }

  String _normalizeStreamErrorMessage(DioException err) {
    final responseData = err.response?.data;
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message']?.toString();
      if (message != null && message.trim().isNotEmpty) {
        return message;
      }
    }

    final responseText = responseData?.toString() ?? '';
    if (responseText.trim().isNotEmpty) {
      return responseText;
    }

    return err.message?.trim().isNotEmpty == true
        ? err.message!
        : 'تعذر الاتصال بخدمة تتبع الحافلة الأقرب';
  }
}
