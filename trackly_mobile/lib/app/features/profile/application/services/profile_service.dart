import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


@immutable
class ProfileService {
  static ProfileService? _instance;

  final Ref ref;

  const ProfileService._({
    required this.ref,
  });

  static ProfileService getInstance({
    required Ref ref,
  }) {
    _instance ??= ProfileService._(
      ref: ref,
    );

    return _instance!;
  }

  // ProfileUser get currentUser {
  //   final appStorage = ref.read(
  //     appStorageProvider,
  //   );

  //   final id = appStorage.read<String>(
  //     key: AppStorageKeys.userId,
  //     defaultValue: '',
  //   );
  //   final name = appStorage.read<String>(
  //     key: AppStorageKeys.name,
  //     defaultValue: '',
  //   );
  //   final email = appStorage.read<String>(
  //     key: AppStorageKeys.email,
  //     defaultValue: '',
  //   );
  //   final roleValue = appStorage.read<String>(
  //     key: AppStorageKeys.role,
  //     defaultValue: UserRoleEnum.recipient.name,
  //   );

  //   return ProfileUser(
  //     id: id,
  //     name: name,
  //     email: email,
  //     role: UserRoleEnum.fromValue(
  //       roleValue,
  //     ),

  //   );
  // }

  // Future<ProfileUser> fetchCurrentUser() async {
  //   return currentUser;
  // }
}
