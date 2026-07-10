import 'dart:async';

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../features/auth/application/services/auth_service.dart';
import '../../../features/auth/providers/auth_service_provider.dart';
import '../../../routing/app_router_provider.dart';
import '../../../routing/app_router_routes.dart';
import '../../error/exceptions.dart';
import '../../error/failures.dart';
import '../../utils/app_log_utils.dart';
import '../../values/constants/app_urls.dart';
import '../api_caller.dart';
import '../enums/app_status_code_enums.dart';

enum RefreshResult { success, failed, timeout }

class AppDioAuthInterceptor extends Interceptor {
  static const _retriedKey = '__app_auth_retried';
  static const _navKey = '__auth_nav_done';

  final Dio dio;
  final Ref ref;
  final AuthService authService;

  Completer<RefreshResult>? _refreshCompleter;

  AppDioAuthInterceptor({required this.dio, required this.ref})
    : authService = ref.read(authServiceProvider);

  // @override
  // void onRequest(
  //   RequestOptions options,
  //   RequestInterceptorHandler handler,
  // ) async {
  //   final authorizationHeaders =
  //       options.headers[authorizationHeader]?.toString() ?? '';
  //   // To skip refresh api and any un-authorized one from token expiration check
  //   if (options.path == AppUrls.refresh || authorizationHeaders.isEmpty) {
  //     return handler.next(options);
  //   }

  //   var token = await authService.accessToken;
  //   final isTokenExpired = JwtUtils.isTokenExpired(token: token);
  //   if (isTokenExpired) {
  //     print('Token expired. Attempting to refresh...');

  //     final isTokenRefreshed =
  //         await _refreshToken(timeout: Duration(seconds: 10)).timeout(
  //           Duration(seconds: 10),
  //           onTimeout: () {
  //             print('Token refresh timed out.');
  //             return false;
  //           },
  //         );

  //     if (!isTokenRefreshed) {
  //       AppLogUtils.errorLog(
  //         message: 'Token refresh failed. Rejecting request.',
  //       );

  //       return handler.reject(
  //         DioException(
  //           requestOptions: options,
  //           type: DioExceptionType.unknown,
  //           response: Response(
  //             requestOptions: options,
  //             statusCode: 401,
  //             statusMessage: 'Unauthorized',
  //           ),
  //         ),
  //         true,
  //       );
  //     }

  //     token = await authService.accessToken;
  //     options.headers[authorizationHeader] = 'Bearer $token';
  //   }

  //   return handler.next(options);
  // }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode ?? -1;
    final appStatusCodeEnum = AppStatusCodeEnum.from(code: statusCode);

    // Cause it is processed in AppDioErrorInterceptor
    //  || appStatusCodeEnum == AppStatusCodeEnum.forbidden
    if (appStatusCodeEnum != AppStatusCodeEnum.unAuthorized) {
      return handler.next(err);
    }

    final requestOptions = err.requestOptions;

    final alreadyRetried = requestOptions.extra[_retriedKey] == true;
    if (alreadyRetried) {
      return _handleUnAuthorizedNavigationAndForward(
        err: err,
        handler: handler,
      );
    }

    final authorizationHeaders =
        requestOptions.headers[authorizationHeader]?.toString() ?? '';

    // To skip refresh api and any un-authorized one from token expiration check
    if (requestOptions.path == AppUrls.refresh ||
        authorizationHeaders.isEmpty) {
      return _handleUnAuthorizedNavigationAndForward(
        err: err,
        handler: handler,
      );
    }

    ///region Authorization error

    final refreshResult = await _refreshToken(
      timeout: const Duration(seconds: 10),
    );
    if (refreshResult == RefreshResult.timeout) {
      return handler.next(err);
    }
    if (refreshResult == RefreshResult.failed) {
      return _handleUnAuthorizedNavigationAndForward(
        err: err,
        handler: handler,
      );
    }

    final token = await authService.accessToken;
    requestOptions.extra[_retriedKey] = true;
    requestOptions.headers[authorizationHeader] = 'Bearer $token';

    try {
      final clonedData = _cloneRequestData(requestOptions.data);
      final nextOptions = requestOptions.copyWith(data: clonedData);
      final response = await dio.fetch(nextOptions);
      return handler.resolve(response);
    } on DioException catch (dioException) {
      return handler.next(dioException);
    } catch (_) {
      return handler.next(err);
    }

    ///endregion Authorization error
  }

  dynamic _cloneRequestData(dynamic data) {
    if (data == null) {
      return null;
    }

    if (data is FormData) {
      return _cloneFormData(data);
    }

    if (data is Map) {
      return Map<dynamic, dynamic>.from(data);
    }

    if (data is List) {
      return List<dynamic>.from(data);
    }

    return data;
  }

  FormData _cloneFormData(FormData original) {
    final cloned = FormData();

    cloned.fields.addAll(original.fields);

    for (final entry in original.files) {
      final file = entry.value;

      final dynamicFile = file as dynamic;
      final path =
          dynamicFile.filePath as String? ?? dynamicFile.filepath as String?;

      if (path == null) {
        AppLogUtils.errorLog(
          message:
              'Cannot retry multipart request: MultipartFile has no file path.',
        );
        continue;
      }

      cloned.files.add(
        MapEntry(
          entry.key,
          MultipartFile.fromFileSync(
            path,
            filename: file.filename,
            contentType: file.contentType,
            headers: file.headers,
          ),
        ),
      );
    }

    return cloned;
  }

  Future<void> _handleUnAuthorizedNavigationAndForward({
    required DioException err,
    required ErrorInterceptorHandler handler,
  }) async {
    // Prevents multiple navigation (per request)
    if (err.requestOptions.extra[_navKey] == true) {
      return handler.next(err);
    }

    err.requestOptions.extra[_navKey] = true;

    final router = ref.read(goRouterProvider);

    try {
      while (router.canPop()) {
        router.pop();
      }
    } catch (exception) {
      AppLogUtils.errorLog(
        message: 'Failed to pop route',
        exception: exception,
      );
    }

    if (router.state.fullPath != AppRouterEnum.login.path) {
      router.replace(AppRouterEnum.login.path);
    }

    // Improvement:
    // - Prefer DioExceptionType.badResponse for HTTP 4xx/5xx.
    // - Preserve existing response (body/headers) when possible.
    final oldResponse = err.response;
    final updatedResponse = Response(
      requestOptions: oldResponse?.requestOptions ?? err.requestOptions,
      data: oldResponse?.data,
      headers: oldResponse?.headers,
      isRedirect: oldResponse?.isRedirect ?? false,
      redirects: oldResponse?.redirects ?? const [],
      extra: oldResponse?.extra ?? <String, dynamic>{},
      statusCode: AppStatusCodeEnum.unAuthorized.code,
      statusMessage: AppStatusCodeEnum.unAuthorized.messageKey,
    );

    return handler.next(
      DioException(
        requestOptions: err.requestOptions,
        type: DioExceptionType.badResponse,
        response: updatedResponse,
        error: err.error,
        stackTrace: err.stackTrace,
        message: err.message,
      ),
    );
  }

  Future<RefreshResult> _refreshToken({required Duration timeout}) async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<RefreshResult>();
    _refreshCompleter = completer;

    final perAttemptTimeout = Duration(
      milliseconds: (timeout.inMilliseconds / 2).floor().clamp(
        1000,
        timeout.inMilliseconds,
      ),
    );

    Future<RefreshResult> runAttempt({required int attempt}) async {
      final attemptCompleter = Completer<RefreshResult>();

      final timer = Timer(perAttemptTimeout, () {
        if (!attemptCompleter.isCompleted) {
          attemptCompleter.complete(RefreshResult.timeout);
        }
      });

      try {
        await authService.refresh(
          onSuccess: () async {
            if (!attemptCompleter.isCompleted) {
              attemptCompleter.complete(RefreshResult.success);
            }
          },
          onFailure: (Failure failure) async {
            if (!attemptCompleter.isCompleted) {
              attemptCompleter.complete(RefreshResult.failed);
            }
          },
        );

        if (!attemptCompleter.isCompleted) {
          attemptCompleter.complete(RefreshResult.timeout);
        }
      } on ServerException catch (exception) {
        AppLogUtils.errorLog(
          exception: exception,
          message: 'Server error during token refresh (attempt $attempt).',
        );

        if (!attemptCompleter.isCompleted) {
          attemptCompleter.complete(RefreshResult.failed);
        }
      } catch (exception) {
        AppLogUtils.errorLog(
          exception: exception,
          message: 'Non-server error during token refresh (attempt $attempt).',
        );

        if (!attemptCompleter.isCompleted) {
          attemptCompleter.complete(RefreshResult.timeout);
        }
      } finally {
        timer.cancel();
      }

      final result = await attemptCompleter.future;

      AppLogUtils.infoLog(
        message: 'auth_refresh_result=${result.name}, attempt=$attempt',
      );

      return result;
    }

    try {
      final firstAttemptResult = await runAttempt(attempt: 1);

      if (firstAttemptResult == RefreshResult.success ||
          firstAttemptResult == RefreshResult.failed) {
        if (!completer.isCompleted) {
          completer.complete(firstAttemptResult);
        }

        return completer.future;
      }

      final secondAttemptResult = await runAttempt(attempt: 2);

      if (!completer.isCompleted) {
        completer.complete(secondAttemptResult);
      }

      return completer.future;
    } finally {
      _refreshCompleter = null;
    }
  }
}
