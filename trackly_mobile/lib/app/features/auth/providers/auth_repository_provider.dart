import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import 'auth_local_data_source_provider.dart';
import 'auth_remote_data_source_provider.dart';

final authRepositoryProvider = Provider.autoDispose<AuthRepository>(
  (ref) {
    final authLocalDataSource = ref.read(
      authLocalDataSourceProvider,
    );

    final authRemoteDataSource = ref.read(
      authRemoteDataSourceProvider,
    );

    return AuthRepositoryImpl(
      localDataSource: authLocalDataSource,
      remoteDataSource: authRemoteDataSource,
    );
  },
);
