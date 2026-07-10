
class AuthLogin {
  final String id;
  final String name;
  final String phone;
  final String accessToken;
  final String refreshToken;

  AuthLogin({
    required this.id,
    required this.name,
    required this.phone,
    required this.accessToken,
    required this.refreshToken,
  });
}
