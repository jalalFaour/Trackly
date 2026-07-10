import '../../../data/models/remote/response/auth_login_response_dto.dart';
import '../auth_login.dart';

extension AuthLoginResponseDtoExtensions on AuthLoginResponseDto {
  AuthLogin get toDomain => AuthLogin(
    id: id,
    name: name,
    phone: phone,
    accessToken: accessToken,
    refreshToken: refreshToken,
  );
}
