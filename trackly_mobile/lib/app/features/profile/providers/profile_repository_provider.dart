import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/repositories/profile_repository_impl.dart';
import '../domain/repositories/profile_repository.dart';
import 'profile_local_data_source_provider.dart';
import 'profile_remote_data_source_provider.dart';

final profileRepositoryProvider = Provider.autoDispose<ProfileRepository>(
  (ref) {
    final profileLocalDataSource = ref.read(
      profileLocalDataSourceProvider,
    );

    final profileRemoteDataSource = ref.read(
      profileRemoteDataSourceProvider,
    );

    return ProfileRepositoryImpl(
      localDataSource: profileLocalDataSource,
      remoteDataSource: profileRemoteDataSource,
    );
  },
);
