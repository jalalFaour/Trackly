class AuthLoginData {
  final String phone;
  final String password;

  AuthLoginData({
    required this.phone,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'password': password,
  };
}
