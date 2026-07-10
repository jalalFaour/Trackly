enum UserRoleEnum {
  donor,
  recipient;

  String get displayName {
    switch (this) {
      case UserRoleEnum.donor:
        return 'Donor';
      case UserRoleEnum.recipient:
        return 'Recipient';
    }
  }

  String get defaultNavSubPage {
    switch (this) {
      case UserRoleEnum.donor:
        return 'myDonations';
      case UserRoleEnum.recipient:
        return 'donations';
    }
  }

  List<String> get navSubPages {
    switch (this) {
      case UserRoleEnum.donor:
        return const [
          'myDonations',
          'requests',
          'profile',
        ];
      case UserRoleEnum.recipient:
        return const [
          'donations',
          'categories',
          'requests',
          'profile',
        ];
    }
  }

  static UserRoleEnum fromValue(String? value) {
    return UserRoleEnum.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRoleEnum.recipient,
    );
  }
}
