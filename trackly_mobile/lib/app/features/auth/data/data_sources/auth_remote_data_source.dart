import 'package:dartz/dartz.dart';
import 'package:trackly/app/core/data/remote_data_state.dart';
import 'package:trackly/app/core/error/exceptions.dart';
import 'package:trackly/app/core/network/api_caller.dart';
import 'package:trackly/app/core/network_response/network_response.dart';
import 'package:trackly/app/core/values/constants/app_urls.dart';
import 'package:trackly/app/features/auth/application/services/auth_service.dart';

import '../models/remote/request/auth_login_request_dto.dart';
import '../models/remote/request/auth_register_request_dto.dart';
import '../models/remote/response/auth_login_response_dto.dart';

abstract class AuthRemoteDataSource {
  Future<RemoteDataState<Unit>?> register({
    required AuthRegisterRequestDto data,
  });

  Future<RemoteDataState<AuthLoginResponseDto>?> login({
    required AuthLoginRequestDto data,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiCaller apiCaller;
  final AuthService authService;

  AuthRemoteDataSourceImpl({
    required this.apiCaller,
    required this.authService,
  });

  @override
  Future<RemoteDataState<Unit>?> register({
    required AuthRegisterRequestDto data,
  }) async {
    RemoteDataState<Unit>? dataState;

    await apiCaller.post(
      token: await authService.accessToken,
      url: AppUrls.register,
      data: data.toJson(),
      onSuccess: (dynamic data) async {
        final networkResponse = NetworkResponse.fromJson(data, null);

        if (!networkResponse.isSuccess) {
          throw ServerException(
            key: networkResponse.key,
            message: networkResponse.message,
          );
        }

        dataState = RemoteDataState.done(
          data: unit,
          pagedList: networkResponse.paging,
          key: networkResponse.key,
          message: networkResponse.message,
        );
      },
      onError: (String? key, String message) {
        throw ServerException(key: key, message: message);
      },
    );

    return dataState;
  }

  @override
  Future<RemoteDataState<AuthLoginResponseDto>?> login({
    required AuthLoginRequestDto data,
  }) async {
    RemoteDataState<AuthLoginResponseDto>? dataState;

    await apiCaller.post(
      token: await authService.accessToken,
      url: AppUrls.login,
      data: data.toJson(),
      onSuccess: (dynamic data) async {
        final networkResponse = NetworkResponse.fromJson<AuthLoginResponseDto>(
          data,
          AuthLoginResponseDto.fromJson,
        );

        if (!networkResponse.isSuccess) {
          throw ServerException(
            key: networkResponse.key,
            message: networkResponse.message,
          );
        }

        dataState = RemoteDataState.done(
          data: networkResponse.data!,
          pagedList: networkResponse.paging,
          key: networkResponse.key,
          message: networkResponse.message,
        );
      },
      onError: (String? key, String message) {
        throw ServerException(key: key, message: message);
      },
    );

    return dataState;
  }
}
