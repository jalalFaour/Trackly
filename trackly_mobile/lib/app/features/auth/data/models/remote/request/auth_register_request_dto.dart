
class AuthRegisterRequestDto {
  final String name;
  final String phone;
  final String password;

  AuthRegisterRequestDto({
    required this.name,
    required this.phone,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'password': password,
  };
}
