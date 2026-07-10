class AuthLoginRequestDto {
  final String phone;
  final String password;


  AuthLoginRequestDto({
    required this.phone,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'password': password,
  };
}
