import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

const _healthCheckEndPoint = 'healthCheck';
const _googlePingUrl = 'https://www.google.com';
const _healthCacheDurationSeconds = 30;
const _onChangeTimeoutSeconds = 3;
const _debounceDurationMilliseconds = 400;

class ConnectionStatus {
  final List<ConnectivityResult> results;
  final bool isOnline;
  final Duration? backendLatency;

  const ConnectionStatus({
    required this.results,
    required this.isOnline,
    this.backendLatency,
  });
}

class BackendHealth {
  final bool isHealthy;
  final Duration? latency;
  final int? statusCode;

  const BackendHealth({
    required this.isHealthy,
    this.latency,
    this.statusCode,
  });
}

abstract class AppNetworkUtils {
  Future<bool> get isConnected;

  Future<bool> get isConnectedFresh;

  Future<Duration?> get backendLatency;

  Future<Duration?> get backendLatencyFresh;
}

class AppNetworkUtilsImpl implements AppNetworkUtils {
  static final instance = AppNetworkUtilsImpl._();

  AppNetworkUtilsImpl._();

  @override
  Future<bool> get isConnected {
    if (kIsWeb) {
      return Future.value(
        true,
      );
    }

    return NetworkConnectivity.instance.isConnected();
  }

  @override
  Future<bool> get isConnectedFresh {
    return NetworkConnectivity.instance.isConnectedFresh();
  }

  @override
  Future<Duration?> get backendLatency {
    return NetworkConnectivity.instance.pingBackend();
  }

  @override
  Future<Duration?> get backendLatencyFresh {
    return NetworkConnectivity.instance.pingBackendFresh();
  }
}

class NetworkConnectivity {
  static final _instance = NetworkConnectivity._();

  static NetworkConnectivity get instance => _instance;

  static const _healthCacheDuration = Duration(
    seconds: _healthCacheDurationSeconds,
  );

  static const _onChangeTimeout = Duration(
    seconds: _onChangeTimeoutSeconds,
  );

  static const _debounceDuration = Duration(
    milliseconds: _debounceDurationMilliseconds,
  );

  static Uri get _healthUri {
    // return Uri.parse(
    //   '${AppUrls.apiUrl}$_healthCheckEndPoint',
    // );

    return Uri.parse(
      _googlePingUrl,
    );
  }

  final _networkConnectivity = Connectivity();

  final _statusController = StreamController<ConnectionStatus>.broadcast();
  final _healthController = StreamController<BackendHealth>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _initialised = false;
  Timer? _debounceTimer;

  List<ConnectivityResult> _lastConnectivityResults = const [];

  BackendHealth? _lastHealth;
  DateTime? _lastHealthAt;
  Future<BackendHealth>? _ongoingHealthCheck;

  Stream<ConnectionStatus> get statusStream => _statusController.stream;

  Stream<BackendHealth> get healthStream => _healthController.stream;

  NetworkConnectivity._();

  Future<void> initialise() async {
    if (_initialised) {
      return;
    }
    _initialised = true;

    final result = await _networkConnectivity.checkConnectivity();
    _lastConnectivityResults = result;

    await _updateStatus(
      result,
      forceRefresh: true,
      timeout: _onChangeTimeout,
    );

    _connectivitySub = _networkConnectivity.onConnectivityChanged.listen(
      (
        List<ConnectivityResult> result,
      ) {
        _lastConnectivityResults = result;

        _debounceTimer?.cancel();
        _debounceTimer = Timer(
          _debounceDuration,
          () {
            unawaited(
              _updateStatus(
                result,
                forceRefresh: true,
                timeout: _onChangeTimeout,
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> isConnected() async {
    final health = await checkBackendHealth();
    return health.isHealthy;
  }

  Future<bool> isConnectedFresh({
    Duration timeout = const Duration(
      seconds: 5,
    ),
  }) async {
    final health = await checkBackendHealth(
      forceRefresh: true,
      timeout: timeout,
    );

    return health.isHealthy;
  }

  Future<Duration?> pingBackend({
    Duration timeout = const Duration(
      seconds: 5,
    ),
  }) async {
    final health = await checkBackendHealth(
      timeout: timeout,
    );
    if (!health.isHealthy) {
      return null;
    }

    return health.latency;
  }

  Future<Duration?> pingBackendFresh({
    Duration timeout = const Duration(
      seconds: 5,
    ),
  }) async {
    final health = await checkBackendHealth(
      forceRefresh: true,
      timeout: timeout,
    );

    if (!health.isHealthy) {
      return null;
    }

    return health.latency;
  }

  Future<BackendHealth> checkBackendHealth({
    Duration timeout = const Duration(
      seconds: 10,
    ),
    Duration cacheDuration = _healthCacheDuration,
    bool forceRefresh = false,
    String? expectedBodyContains,
  }) async {
    if (kIsWeb) {
      final hasBaseConnection =
          _lastConnectivityResults.isNotEmpty &&
          !_lastConnectivityResults.contains(
            ConnectivityResult.none,
          );

      final webHealth = BackendHealth(
        isHealthy: hasBaseConnection,
      );
      _cacheHealth(
        webHealth,
      );
      return webHealth;
    }

    final now = DateTime.now();
    final lastAt = _lastHealthAt;
    if (!forceRefresh && _lastHealth != null && lastAt != null) {
      final age = now.difference(
        lastAt,
      );
      if (age < cacheDuration) {
        return _lastHealth!;
      }
    }

    final ongoing = _ongoingHealthCheck;
    if (ongoing != null) {
      return ongoing;
    }

    final future = _performHealthCheck(
      timeout: timeout,
      expectedBodyContains: expectedBodyContains,
    );

    _ongoingHealthCheck = future;

    try {
      final health = await future;
      _cacheHealth(
        health,
      );
      return health;
    } finally {
      _ongoingHealthCheck = null;
    }
  }

  Future<BackendHealth> _performHealthCheck({
    required Duration timeout,
    required String? expectedBodyContains,
  }) async {
    final client = HttpClient()
      ..connectionTimeout = timeout
      ..idleTimeout = timeout;

    try {
      final stopwatch = Stopwatch()..start();

      Future<HttpClientResponse> doHead() async {
        final request = await client.openUrl(
          'HEAD',
          _healthUri,
        );
        request.followRedirects = false;
        return request.close();
      }

      Future<HttpClientResponse> doGet() async {
        final request = await client.getUrl(
          _healthUri,
        );
        request.followRedirects = false;
        return request.close();
      }

      HttpClientResponse response;

      try {
        response = await doHead();
      } on Exception {
        response = await doGet();
      }

      if (response.statusCode == 405 || response.statusCode == 501) {
        await response.drain();
        response = await doGet();
      }

      final isRedirect = response.isRedirect || (response.statusCode >= 300 && response.statusCode < 400);
      if (isRedirect) {
        await response.drain();
        stopwatch.stop();
        return BackendHealth(
          isHealthy: false,
          statusCode: response.statusCode,
        );
      }

      final okStatus = response.statusCode >= 200 && response.statusCode < 300;
      var bodyOk = true;
      if (okStatus && expectedBodyContains != null) {
        bodyOk = await _responseBodyContains(
          response,
          expectedBodyContains,
        );
      } else {
        await response.drain();
      }

      stopwatch.stop();

      final ok = okStatus && bodyOk;
      return BackendHealth(
        isHealthy: ok,
        latency: ok ? stopwatch.elapsed : null,
        statusCode: response.statusCode,
      );
    } catch (_) {
      return const BackendHealth(
        isHealthy: false,
      );
    } finally {
      client.close(
        force: true,
      );
    }
  }

  Future<bool> _responseBodyContains(
    HttpClientResponse response,
    String needle,
  ) async {
    const maxBytes = 2048;

    final bytes = <int>[];
    var total = 0;

    await for (final chunk in response) {
      if (chunk.isEmpty) {
        continue;
      }

      final remaining = maxBytes - total;
      if (remaining <= 0) {
        break;
      }

      if (chunk.length <= remaining) {
        bytes.addAll(
          chunk,
        );
        total += chunk.length;
      } else {
        bytes.addAll(
          chunk.take(
            remaining,
          ),
        );
        total += remaining;
        break;
      }
    }

    final text = utf8.decode(
      bytes,
      allowMalformed: true,
    );

    return text.contains(
      needle,
    );
  }

  void _cacheHealth(
    BackendHealth health,
  ) {
    final prev = _lastHealth;

    _lastHealth = health;
    _lastHealthAt = DateTime.now();

    // CHANGE (5): emit only if changed (reduces stream noise).
    if (_healthController.isClosed) {
      return;
    }

    final prevLatencyMs = prev?.latency?.inMilliseconds;
    final nextLatencyMs = health.latency?.inMilliseconds;

    final changed = prev == null || prev.isHealthy != health.isHealthy || prev.statusCode != health.statusCode || prevLatencyMs != nextLatencyMs;

    if (changed) {
      _healthController.add(
        health,
      );
    }
  }

  Future<void> _updateStatus(
    List<ConnectivityResult> result, {
    required bool forceRefresh,
    required Duration timeout,
  }) async {
    var isOnline = false;
    Duration? latency;

    try {
      final hasBaseConnection = !result.contains(
        ConnectivityResult.none,
      );
      if (hasBaseConnection) {
        final health = await checkBackendHealth(
          forceRefresh: forceRefresh,
          timeout: timeout,
        );

        isOnline = health.isHealthy;
        latency = health.latency;
      } else {
        isOnline = false;
        latency = null;

        _cacheHealth(
          const BackendHealth(
            isHealthy: false,
          ),
        );
      }
    } on SocketException {
      isOnline = false;
      latency = null;

      _cacheHealth(
        const BackendHealth(
          isHealthy: false,
        ),
      );
    }

    if (_statusController.isClosed) {
      return;
    }

    _statusController.add(
      ConnectionStatus(
        results: result,
        isOnline: isOnline,
        backendLatency: latency,
      ),
    );
  }

  void disposeStream() {
    _connectivitySub?.cancel();
    _connectivitySub = null;

    _debounceTimer?.cancel();
    _debounceTimer = null;

    _statusController.close();
    _healthController.close();

    _initialised = false;
  }
}
