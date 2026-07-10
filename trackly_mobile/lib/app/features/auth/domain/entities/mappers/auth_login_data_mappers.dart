import '../../../data/models/remote/request/auth_login_request_dto.dart';
import '../auth_login_data.dart';

extension AuthLoginDataExtensions on AuthLoginData {
  AuthLoginRequestDto get toDto => AuthLoginRequestDto(
    phone: phone,
    password: password,
  );
}
