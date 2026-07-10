import 'package:dio/dio.dart';

import '../../utils/app_log_utils.dart';

class AppDioLoggerInterceptor extends Interceptor {
  static const _startTimeKey = '__app_logger_start_time';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startTimeKey] = DateTime.now().millisecondsSinceEpoch;

    AppLogUtils.infoLog(
      message: '${options.method} => ${options.baseUrl}${options.path}',
    );

    final rangeHeader = options.headers['range'];
    if (rangeHeader != null) {
      AppLogUtils.debugLog(message: 'Range => $rangeHeader');
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final requestOptions = response.requestOptions;

    final startTime = requestOptions.extra[_startTimeKey] as int?;
    final endTime = DateTime.now().millisecondsSinceEpoch;
    final elapsedMs = startTime != null ? endTime - startTime : null;

    AppLogUtils.infoLog(
      message:
          '${requestOptions.method} => '
          '(StatusCode: ${response.statusCode}) '
          '${requestOptions.baseUrl}${requestOptions.path}'
          ' ===== [Time elapsed: ${elapsedMs ?? 'n/a'} ms]',
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final requestOptions = err.requestOptions;

    final startTime = requestOptions.extra[_startTimeKey] as int?;
    final endTime = DateTime.now().millisecondsSinceEpoch;
    final elapsedMs = startTime != null ? endTime - startTime : null;

    AppLogUtils.errorLog(
      message: '================================================',
    );
    AppLogUtils.errorLog(
      message:
          '${requestOptions.method} => '
          '(StatusCode: ${err.response?.statusCode ?? 'n/a'}) '
          '${requestOptions.baseUrl}${requestOptions.path}'
          ' ===== [Time elapsed: ${elapsedMs ?? 'n/a'} ms]',
    );
    AppLogUtils.errorLog(exception: err, stackTrace: err.stackTrace);
    AppLogUtils.errorLog(
      message: '================================================',
    );

    handler.next(err);
  }
}
