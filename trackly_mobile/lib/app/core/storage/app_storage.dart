import 'package:flutter/foundation.dart' show immutable;
import 'package:get_storage/get_storage.dart';

part 'app_storage_keys.dart';

@immutable
class AppStorage {
  static AppStorage? _instance;

  final GetStorage _getStorage;

  AppStorage._() : _getStorage = GetStorage();

  static AppStorage getInstance() {
    _instance ??= AppStorage._();

    return _instance!;
  }

  Future<void> init() async {
    await GetStorage.init();
  }

  T read<T>({
    required String key,
    required T defaultValue,
  }) =>
      _getStorage.read<T>(
        key,
      ) ??
      defaultValue;

  Future<void> write({
    required String key,
    required dynamic value,
  }) =>
      _getStorage.write(
        key,
        value,
      );

  Future<void> remove({
    required String key,
  }) =>
      _getStorage.remove(
        key,
      );

  Future<void> removeAll() => _getStorage.erase();
}
