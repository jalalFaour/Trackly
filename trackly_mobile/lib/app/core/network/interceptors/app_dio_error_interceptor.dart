import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trackly/app/core/extensions/string_extensions.dart';

import '../../network_response/network_response.dart';
import '../enums/app_status_code_enums.dart';
import '../error_data.dart';

class AppDioErrorInterceptor extends Interceptor {
  final Ref ref;

  AppDioErrorInterceptor({required this.ref});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode ?? -1;
    final appStatusCodeEnum = AppStatusCodeEnum.from(code: statusCode);

    // This is processed in AppDioAuthInterceptor.
    //  || appStatusCodeEnum == AppStatusCodeEnum.forbidden
    if (appStatusCodeEnum == AppStatusCodeEnum.unAuthorized) {
      return handler.next(err);
    }

    String? key;
    String? message;

    final data = err.response?.data;

    // NetworkResponse or BadRequest
    if (data is Map<String, dynamic>) {
      final networkResponseKeysCondition = networkResponseRequiredKeys.every(
        (element) => data.containsKey(element),
      );

      // NetworkResponse
      if (networkResponseKeysCondition) {
        final networkResponse = NetworkResponse.fromJson(data, null);
        key = networkResponse.key;
        message = networkResponse.message;
      }
      // BadRequest
      else if (statusCode == AppStatusCodeEnum.badRequest.code) {
        message = _processApiErrors(response: data);
      }
    }
    // Message from server
    else {
      message = err.response?.data?.toString();
    }
    message = message!.isNullOrEmpty
        ? appStatusCodeEnum.messageKey
        : message.trim();

    // message = message.isNullOrEmpty
    //     ? ref.read(
    //         appGlobalWordsTranslationProvider(
    //           appStatusCodeEnum.messageKey,
    //         ),
    //       )
    //     : message!.trim();

    final updatedException = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: message,
      stackTrace: err.stackTrace,
      message: message,
    )..requestOptions.extra['key'] = key;

    return handler.next(updatedException);
  }

  String _processApiErrors({required Map<String, dynamic> response}) {
    final directMessage = _extractDirectMessage(response);
    if (!directMessage.isNullOrEmpty) {
      return directMessage!;
    }

    final dataContainsErrorsCondition = response.containsKey('errors');
    final dataContainsMessageCondition = response.containsKey('errorMessage');

    if (dataContainsMessageCondition && !dataContainsErrorsCondition) {
      final errorMessage = response['errorMessage'];
      return errorMessage is String ? errorMessage : '';
    }

    final rawErrors = response['errors'];

    if (rawErrors is Map<String, dynamic>) {
      final fieldErrors = rawErrors.entries
          .where((entry) => entry.value is List)
          .map((entry) {
            final messages = (entry.value as List)
                .whereType<String>()
                .map((message) => message.trim())
                .where((message) => message.isNotEmpty)
                .join('\n- ');

            if (messages.isEmpty) {
              return '';
            }

            return '${entry.key}:\n- $messages';
          })
          .where((message) => message.isNotEmpty)
          .join('\n\n');

      if (fieldErrors.isNotEmpty) {
        return fieldErrors;
      }
    }

    final errorsList = rawErrors is List ? rawErrors : const <dynamic>[];
    final errorsMaps = errorsList.whereType<Map<String, dynamic>>();

    final errors = errorsMaps
        .map((element) => AppError.fromJson(element))
        .toList();

    final errorMessage = errors.fold('', (
      String errorMessage,
      AppError appError,
    ) {
      final errorMessages = appError.errorMessages.join('\n- ');
      return '$errorMessage${appError.propertyName}:\n- $errorMessages\n\n';
    });

    return errorMessage.trim();
  }

  String? _extractDirectMessage(Map<String, dynamic> response) {
    const possibleMessageKeys = [
      'message',
      'errorMessage',
      'error',
      'detail',
      'title',
    ];

    for (final key in possibleMessageKeys) {
      final value = response[key];

      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }

      if (value is List) {
        final listMessage = value
            .whereType<String>()
            .map((element) => element.trim())
            .where((element) => element.isNotEmpty)
            .join('\n');

        if (listMessage.isNotEmpty) {
          return listMessage;
        }
      }
    }

    return null;
  }
}
