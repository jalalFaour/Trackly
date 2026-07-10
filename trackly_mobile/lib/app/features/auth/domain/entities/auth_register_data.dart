
class AuthRegisterData {
  final String name;
  final String password;
  final String phone;

  AuthRegisterData({
    required this.name,
    required this.password,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'password': password,
    'phone': phone,
  };
}
