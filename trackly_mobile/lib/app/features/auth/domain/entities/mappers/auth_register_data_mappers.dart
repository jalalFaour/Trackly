import '../../../data/models/remote/request/auth_register_request_dto.dart';
import '../auth_register_data.dart';

extension AuthRegisterDataExtensions on AuthRegisterData {
  AuthRegisterRequestDto get toDto => AuthRegisterRequestDto(
    name: name,
    phone: phone,
    password: password,
  );
}
