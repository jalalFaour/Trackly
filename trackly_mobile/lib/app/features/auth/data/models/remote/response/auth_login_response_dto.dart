class AuthLoginResponseDto {
  final String id;
  final String name;
  final String phone;
  final String accessToken;
  final String refreshToken;

  AuthLoginResponseDto({
    required this.id,
    required this.name,
    required this.phone,
    required this.accessToken,
    required this.refreshToken,
  });

  /// Accepts either the full server response or the inner `data` map.
  factory AuthLoginResponseDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final user = data['user'] as Map<String, dynamic>? ?? data;

    return AuthLoginResponseDto(
      id: (user['id'] ?? '').toString(),
      name: (user['name'] ?? user['nickName'] ?? '').toString(),
      phone: (user['phone'] ?? '').toString(),
      accessToken: (data['accessToken'] ?? data['token'] ?? '').toString(),
      refreshToken: (data['refreshToken'] ?? '').toString(),
    );
  }
}
