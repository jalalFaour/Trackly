
import '../../../data/models/remote/response/profile_user_response_dto.dart';
import '../profile_user.dart';

extension ProfileUserResponseDtoExtensions on ProfileUserResponseDto {
  ProfileUser get toDomain => ProfileUser(
    id: id,
    name: name,
    phone: phone,
    balance: balance,
  );
}
