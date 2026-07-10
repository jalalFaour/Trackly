import 'package:trackly/app/core/error/failures.dart';
import 'package:trackly/app/core/storage/app_storage.dart';
import 'package:trackly/app/core/storage/app_storage_provider.dart';
import 'package:trackly/app/features/auth/domain/entities/auth_login.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

@immutable
class AuthService {
  static AuthService? _instance;

  final Ref ref;

  const AuthService._({required this.ref});

  static AuthService getInstance({required Ref ref}) {
    _instance ??= AuthService._(ref: ref);

    return _instance!;
  }

  Future<void> storeAuthData({required AuthLogin authLogin}) async {
    final appStorage = ref.read(appStorageProvider);
    await appStorage.write(key: AppStorageKeys.userId, value: authLogin.id);
    await appStorage.write(key: AppStorageKeys.name, value: authLogin.name);
    await appStorage.write(key: AppStorageKeys.phone, value: authLogin.phone);
    await appStorage.write(
      key: AppStorageKeys.accessToken,
      value: authLogin.accessToken,
    );
    await appStorage.write(
      key: AppStorageKeys.refreshToken,
      value: authLogin.refreshToken,
    );
  }

  Future<int> get id async {
    final appStorage = ref.read(appStorageProvider);
    return appStorage.read<int>(key: AppStorageKeys.userId, defaultValue: -1);
  }

  Future<String> get name async {
    final appStorage = ref.read(appStorageProvider);
    return appStorage.read<String>(key: AppStorageKeys.name, defaultValue: '');
  }

  Future<String> get phone async {
    final appStorage = ref.read(appStorageProvider);
    return appStorage.read<String>(key: AppStorageKeys.phone, defaultValue: '');
  }

  Future<String> get accessToken async {
    final appStorage = ref.read(appStorageProvider);
    return appStorage.read<String>(
      key: AppStorageKeys.accessToken,
      defaultValue: '',
    );
  }

  Future<String> get refreshToken async {
    final appStorage = ref.read(appStorageProvider);
    return appStorage.read<String>(
      key: AppStorageKeys.refreshToken,
      defaultValue: '',
    );
  }

  Future<void> refresh({
    required void Function() onSuccess,
    required void Function(Failure failure) onFailure,
  }) async {}
}
