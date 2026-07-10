import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trackly/app/core/network/api_caller_provider.dart';
import 'package:trackly/app/features/auth/providers/auth_service_provider.dart';

import '../data/data_sources/profile_remote_data_source.dart';

final profileRemoteDataSourceProvider =
    Provider.autoDispose<ProfileRemoteDataSource>(
      (ref) {
        final apiCaller = ref.read(
          apiCallerProvider,
        );

        final authService = ref.read(
          authServiceProvider,
        );

        return ProfileRemoteDataSourceImpl(
          apiCaller: apiCaller,
          authService: authService,
        );
      },
    );
