import 'package:collection/collection.dart';

enum AppStatusCodeEnum {
// static const urlNotFound = 'urlNotFound';
// static const noInternetConnection = 'noInternetConnection';
// static const supportInformation = 'supportInformation';

  none(
    code: -1,
    messageKey: '',
  ),
  success(
    code: 200,
    messageKey: 'success',
  ),
  badRequest(
    code: 400,
    messageKey: 'badRequest',
  ),
  unAuthorized(
    code: 401,
    messageKey: 'unAuthorized',
  ),
  paymentRequired(
    code: 402,
    messageKey: 'paymentRequired',
  ),
  forbidden(
    code: 403,
    messageKey: 'forbidden',
  ),
  notFound(
    code: 404,
    messageKey: 'notFound',
  ),
  conflict(
    code: 409,
    messageKey: 'conflict',
  ),
  internalServerError(
    code: 500,
    messageKey: 'internalServerError',
  ),
  networkError(
    code: -1,
    messageKey: 'noInternetConnection',
  ),
  ;

  final int code;
  final String messageKey; // Needs to be translated

  const AppStatusCodeEnum({
    required this.code,
    required this.messageKey,
  });

  factory AppStatusCodeEnum.from({
    required int code,
  }) =>
      AppStatusCodeEnum.values.firstWhereOrNull(
        (element) => element.code == code,
      ) ??
      AppStatusCodeEnum.none;

  static bool isSuccess({
    required int code,
  }) =>
      code >= 200 && code < 300;
}
