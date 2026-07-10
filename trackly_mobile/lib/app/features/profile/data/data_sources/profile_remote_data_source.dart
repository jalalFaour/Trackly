import 'package:trackly/app/core/data/remote_data_state.dart';
import 'package:trackly/app/core/error/exceptions.dart';
import 'package:trackly/app/core/network/api_caller.dart';
import 'package:trackly/app/core/network_response/network_response.dart';
import 'package:trackly/app/core/values/constants/app_urls.dart';
import 'package:trackly/app/features/auth/application/services/auth_service.dart';

import '../models/remote/response/profile_user_response_dto.dart';

abstract class ProfileRemoteDataSource {
  Future<RemoteDataState<ProfileUserResponseDto>?> getProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiCaller apiCaller;
  final AuthService authService;

  ProfileRemoteDataSourceImpl({
    required this.apiCaller,
    required this.authService,
  });

  @override
  Future<RemoteDataState<ProfileUserResponseDto>?> getProfile() async {
    RemoteDataState<ProfileUserResponseDto>? dataState;

    await apiCaller.get(
      token: await authService.accessToken,
      url: AppUrls.profile,
      onSuccess: (dynamic data) async {
        final networkResponse =
            NetworkResponse.fromJson<ProfileUserResponseDto>(
              data,
              (json) => ProfileUserResponseDto.fromJson(json),
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
