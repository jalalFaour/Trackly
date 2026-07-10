import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trackly/app/core/extensions/string_extensions.dart';

import '../../../l10n/providers/locale_provider.dart';
import '../error/exceptions.dart';
import '../utils/app_log_utils.dart';
import '../utils/app_package_utils.dart';
import '../values/constants/app_constants.dart';
import '../values/constants/app_urls.dart';
import 'app_dio_utils.dart';
import 'enums/app_status_code_enums.dart';
import 'interceptors/app_dio_auth_interceptor.dart';
import 'interceptors/app_dio_error_interceptor.dart';
import 'interceptors/app_dio_logger_interceptor.dart';

const authorizationHeader = 'Authorization';

typedef ApiOnSuccess = Future<void> Function(dynamic data);

typedef ApiOnError = void Function(String? key, String errorMessage);

const apiCallerConnectTimeout = Duration(seconds: 120);
const apiCallerReceiveTimeout = Duration(seconds: 120);
const apiCallerSendTimeout = Duration(seconds: 120);

const apiCallerFilesReceiveTimeout = Duration(minutes: 30);
const apiCallerFilesSendTimeout = Duration(minutes: 30);

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      followRedirects: false,
      validateStatus: (int? status) {
        // Accept all statuses so we can read server error bodies (e.g., 401 with message)
        return true;
      },
      baseUrl: AppUrls.apiUrl,
      connectTimeout: apiCallerConnectTimeout,
      receiveTimeout: apiCallerReceiveTimeout,
      responseType: ResponseType.json,
      headers: {
        // EnvConfigs.headerApplicationKey: EnvConfigs.headerApplicationValue,
        // EnvConfigs.headerAppRoleKey: EnvConfigs.headerAppRoleValue,
      },
    ),
  );

  dio.interceptors.addAll([
    AppDioLoggerInterceptor(),
    AppDioErrorInterceptor(ref: ref),
    AppDioAuthInterceptor(dio: dio, ref: ref),
  ]);

  return dio;
});

class ApiCaller {
  static ApiCaller? _instance;

  final Ref ref;
  final Dio dio;

  String? _cachedAppVersion;

  ApiCaller._({required this.ref, required this.dio});

  static ApiCaller getInstance({required Ref ref, required Dio dio}) {
    _instance ??= ApiCaller._(ref: ref, dio: dio);

    return _instance!;
  }

  Future<void> post({
    required String token,
    required String url,
    required Map<String, dynamic> data,
    Map<String, dynamic> queryParameters = const {},
    Options? options,
    CancelToken? cancelToken,
    required ApiOnSuccess onSuccess,
    required ApiOnError onError,
    Function(int sent, int total)? onSendProgress,
    Function(int sent, int total)? onReceiveProgress,
  }) async => await _call(
    actionCallback: () async {
      final requestOptions = await _getRequestOptions(
        token: token,
        responseType: ResponseType.json,
        options: options,
        sentTimeout: apiCallerSendTimeout,
      );

      return dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    },
    onSuccess: onSuccess,
    onError: onError,
  );

  Future<void> postFormData({
    required String url,
    required String token,
    required FormData data,
    Map<String, dynamic> queryParameters = const {},
    CancelToken? cancelToken,
    required ApiOnSuccess onSuccess,
    required ApiOnError onError,
    Function(int sent, int total)? onSendProgress,
    Function(int sent, int total)? onReceiveProgress,
  }) async => await _call(
    actionCallback: () async {
      final requestOptions = await _getRequestOptions(
        token: token,
        responseType: ResponseType.json,
      );

      return dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    },
    onSuccess: onSuccess,
    onError: onError,
  );

  Future<void> delete({
    required String token,
    required String url,
    required Map<String, dynamic> data,
    Map<String, dynamic> queryParameters = const {},
    CancelToken? cancelToken,
    required ApiOnSuccess onSuccess,
    required ApiOnError onError,
  }) async => await _call(
    actionCallback: () async {
      final requestOptions = await _getRequestOptions(
        token: token,
        responseType: ResponseType.json,
        sentTimeout: apiCallerSendTimeout,
      );

      return dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
      );
    },
    onSuccess: onSuccess,
    onError: onError,
  );

  Future<void> put({
    required String token,
    required String url,
    required Map<String, dynamic> data,
    Map<String, dynamic> queryParameters = const {},
    CancelToken? cancelToken,
    required ApiOnSuccess onSuccess,
    required ApiOnError onError,
    Function(int sent, int total)? onSendProgress,
    Function(int sent, int total)? onReceiveProgress,
  }) async => await _call(
    actionCallback: () async {
      final requestOptions = await _getRequestOptions(
        token: token,
        responseType: ResponseType.json,
        sentTimeout: apiCallerSendTimeout,
      );

      return dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    },
    onSuccess: onSuccess,
    onError: onError,
  );

  Future<void> head({
    required String url,
    required String token,
    Map<String, dynamic> data = const {},
    Map<String, dynamic> queryParameters = const {},
    CancelToken? cancelToken,
    required ApiOnSuccess onSuccess,
    required ApiOnError onError,
    Function(int sent, int total)? onReceiveProgress,
  }) async => await _call(
    actionCallback: () async {
      final requestOptions = await _getRequestOptions(
        token: token,
        responseType: ResponseType.json,
        sentTimeout: apiCallerSendTimeout,
      );

      return dio.head(
        url,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
      );
    },
    onSuccess: onSuccess,
    onError: onError,
  );

  Future<void> get({
    required String url,
    required String token,
    // Map<String, dynamic> data = const {},
    Map<String, dynamic> queryParameters = const {},
    CancelToken? cancelToken,
    required ApiOnSuccess onSuccess,
    required ApiOnError onError,
    Function(int sent, int total)? onReceiveProgress,
  }) async => await _call(
    actionCallback: () async {
      final requestOptions = await _getRequestOptions(
        token: token,
        responseType: ResponseType.json,
      );

      return dio.get(
        url,
        // data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    },
    onSuccess: onSuccess,
    onError: onError,
  );

  Future<void> downloadFile({
    required String token,
    required String url,
    Map<String, dynamic> data = const {},
    Map<String, dynamic> queryParameters = const {},
    required String pathToSave,
    required CancelToken cancelToken,
    bool byChunks = false, // Only for large files and need to study use-case
    required ApiOnSuccess onSuccess,
    required ApiOnError onError,
    Function(int sent, int total)? onReceiveProgress,
  }) async => await _call(
    actionCallback: () async {
      final requestOptions = await _getRequestOptions(
        token: token,
        responseType: ResponseType.stream,
        receiveTimeout: apiCallerFilesReceiveTimeout,
      );

      final response = await AppDioUtils.downloadWithChunks(
        dio: dio.clone(options: dio.options.copyWith(baseUrl: '')),
        url: url,
        pathToSave: pathToSave,
        options: requestOptions,
        maxChunkCount: byChunks ? AppConstants.maxChunksCount : 1,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      // final isSuccess = AppStatusCodeEnum.isSuccess(
      //   code: response.statusCode ?? AppStatusCodeEnum.internalServerError.code,
      // );
      // if (isSuccess) {
      //   await onSuccess(
      //     response.data,
      //   );
      // }

      return response;
    },
    onSuccess: onSuccess,
    onError: onError,
  );

  Future<void> downloadFileAsBytesAndSave({
    required String token,
    required String url,
    Map<String, dynamic> data = const {},
    Map<String, dynamic> queryParameters = const {},
    required String pathToSave,
    CancelToken? cancelToken,
    required ApiOnSuccess onSuccess,
    required ApiOnError onError,
    Function(int sent, int total)? onReceiveProgress,
  }) async => await _call(
    actionCallback: () async {
      final requestOptions = await _getRequestOptions(
        token: token,
        responseType: ResponseType.bytes,
        receiveTimeout: apiCallerFilesReceiveTimeout,
      );

      Response<List<int>> response = await dio
          .clone(options: dio.options.copyWith(baseUrl: ''))
          .get<List<int>>(
            url,
            data: data,
            queryParameters: queryParameters,
            options: requestOptions,
            cancelToken: cancelToken,
            onReceiveProgress: onReceiveProgress,
          );

      if (response.statusCode == AppStatusCodeEnum.success.code) {
        final savedFile = await File(pathToSave).create(recursive: true);

        await savedFile.writeAsBytes(
          response.data!,
          mode: FileMode.writeOnly,
          flush: true,
        );
      }

      return response;
    },
    onSuccess: onSuccess,
    onError: onError,
  );

  Future<Uint8List> downloadFileAsBytes({
    required String token,
    required String url,
    Map<String, dynamic> data = const {},
    Map<String, dynamic> queryParameters = const {},
    CancelToken? cancelToken,
    required ApiOnSuccess onSuccess,
    required ApiOnError onError,
    Function(int sent, int total)? onReceiveProgress,
  }) async {
    var fileBytes = Uint8List(0);

    await _call(
      actionCallback: () async {
        final requestOptions = await _getRequestOptions(
          token: token,
          responseType: ResponseType.bytes,
          receiveTimeout: apiCallerFilesReceiveTimeout,
        );

        Response<List<int>> response = await dio
            .clone(options: dio.options.copyWith(baseUrl: ''))
            .get<List<int>>(
              url,
              data: data,
              queryParameters: queryParameters,
              options: requestOptions,
              cancelToken: cancelToken,
              onReceiveProgress: onReceiveProgress,
            );

        if (response.statusCode == AppStatusCodeEnum.success.code) {
          fileBytes = Uint8List.fromList(response.data ?? <int>[]);

          onSuccess(response.data ?? <int>[]);
        }

        return response;
      },
      onSuccess: onSuccess,
      onError: onError,
    );

    return fileBytes;
  }

  Future<void> uploadFile({
    required String token,
    required String url,
    required FormData data,
    Map<String, dynamic> queryParameters = const {},
    CancelToken? cancelToken,
    required ApiOnSuccess onSuccess,
    required ApiOnError onError,
    Function(int sent, int total)? onSendProgress,
    Function(int sent, int total)? onReceiveProgress,
  }) async => await _call(
    actionCallback: () async {
      final requestOptions = await _getRequestOptions(
        token: token,
        responseType: ResponseType.json,
        receiveTimeout: apiCallerFilesReceiveTimeout,
        sentTimeout: apiCallerFilesSendTimeout,
      );

      return dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    },
    onSuccess: onSuccess,
    onError: onError,
  );

  ///region Private Functions

  Future<void> _call({
    required Future<Response<dynamic>> Function() actionCallback,
    required ApiOnSuccess onSuccess,
    required ApiOnError onError,
  }) async {
    try {
      final response = await actionCallback.call();

      final isSuccess = AppStatusCodeEnum.isSuccess(
        code: response.statusCode ?? AppStatusCodeEnum.internalServerError.code,
      );

      if (isSuccess) {
        await onSuccess(response.data);

        return;
      }

      // Try to extract structured error from server response body when available
      String? serverKey;
      String serverMessage = response.data?.toString() ?? '';

      final respData = response.data;
      if (respData is Map) {
        serverKey = respData['key']?.toString();
        serverMessage = (respData['message'] ?? respData['error'] ?? respData)
            .toString();
      }

      onError(serverKey, serverMessage);
    } on ServerException catch (exception, stackTrace) {
      _exceptionHandling(
        exception: exception,
        stackTrace: stackTrace,
        onError: onError,
      );
      rethrow;
    } on DioException catch (exception, stackTrace) {
      _exceptionHandling(
        exception: exception,
        stackTrace: stackTrace,
        onError: onError,
      );
      rethrow;
    } on Exception catch (exception, stackTrace) {
      _exceptionHandling(
        exception: exception,
        stackTrace: stackTrace,
        onError: onError,
      );
      rethrow;
    }
  }

  Future<String> _getAppVersion() async {
    final cached = _cachedAppVersion;
    if (cached != null) {
      return cached;
    }

    final version = await AppPackageUtils.version;
    _cachedAppVersion = version;
    return version;
  }

  Future<Options> _getRequestOptions({
    required String token,
    Options? options,
    ResponseType? responseType,
    Duration? receiveTimeout,
    Duration? sentTimeout,
  }) async {
    final authorizationHeaders = <String, dynamic>{};
    if (token.isNotEmpty) {
      authorizationHeaders[authorizationHeader] = 'Bearer $token';
    }

    final locale = ref.read(localeProvider);

    final version = await _getAppVersion();

    final requestOptions = options ?? Options();
    requestOptions.headers = requestOptions.headers ?? {};
    requestOptions.headers!['Accept-Language'] =
        '${locale.languageCode}-${locale.countryCode}';
    // requestOptions.headers![EnvConfigs.headerAppVersionKey] = version;
    requestOptions.headers!.addAll(authorizationHeaders);

    if (responseType != null) {
      requestOptions.responseType = responseType;
    }

    if (receiveTimeout != null) {
      requestOptions.receiveTimeout = receiveTimeout;
    }

    if (sentTimeout != null) {
      requestOptions.sendTimeout = sentTimeout;
    }

    return requestOptions;
  }

  void _exceptionHandling({
    required Exception exception,
    required StackTrace stackTrace,
    required ApiOnError onError,
  }) {
    final mapped = _mapExceptionToUi(exception: exception);

    onError(mapped.key, mapped.message);

    AppLogUtils.errorLog(
      message: exception.toString(),
      exception: exception,
      stackTrace: stackTrace,
    );
  }

  ({String? key, String message}) _mapExceptionToUi({
    required Exception exception,
  }) {
    String? key;
    String? message;

    // If the backend already provided a ServerException with a message, use it.
    if (exception is ServerException) {
      key = exception.key;
      message = exception.message?.toString();
    }

    DioException? dioException;
    if (exception is DioException) {
      dioException = exception;
      message = message!.isNullOrEmpty ? dioException.message : message;
      key = key ?? dioException.requestOptions.extra['key'] as String?;
    }

    // Network and timeout errors
    final isNetwork =
        exception is SocketException ||
        exception is HttpException ||
        (dioException != null &&
            (dioException.type == DioExceptionType.connectionTimeout ||
                dioException.type == DioExceptionType.sendTimeout ||
                dioException.type == DioExceptionType.receiveTimeout ||
                dioException.type == DioExceptionType.connectionError ||
                dioException.type == DioExceptionType.badCertificate));

    final statusCode = dioException?.response?.statusCode;
    final messageKey = isNetwork
        ? AppStatusCodeEnum.networkError.messageKey
        : AppStatusCodeEnum.from(
            code: statusCode ?? AppStatusCodeEnum.internalServerError.code,
          ).messageKey;

    message = message.isNullOrEmpty ? messageKey : message!.trim();

    return (key: key, message: message);
  }

  ///endregion Private Functions
}
