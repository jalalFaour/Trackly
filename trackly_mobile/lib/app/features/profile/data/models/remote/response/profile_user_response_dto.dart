class ProfileUserResponseDto {
  final String id;
  final String name;
  final String phone;
  final int balance;

  ProfileUserResponseDto({
    required this.id,
    required this.name,
    required this.phone,
    required this.balance,
  });

  /// Accepts either the full server response or the inner `data` map.
  factory ProfileUserResponseDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final user = data['user'] as Map<String, dynamic>? ?? data;

    return ProfileUserResponseDto(
      id: (user['id'] ?? '').toString(),
      name: (user['name'] ?? user['nickName'] ?? '').toString(),
      phone: (user['phone'] ?? '').toString(),
      balance: (data['balance'] ?? 0).toInt(),
    );
  }
}
