import 'package:trackly/app/core/network/api_caller_provider.dart';
import 'package:trackly/app/features/auth/providers/auth_service_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/data_sources/auth_remote_data_source.dart';

final authRemoteDataSourceProvider = Provider.autoDispose<AuthRemoteDataSource>(
  (ref) {
    final apiCaller = ref.read(apiCallerProvider);

    final authService = ref.read(authServiceProvider);

    return AuthRemoteDataSourceImpl(
      apiCaller: apiCaller,
      authService: authService,
    );
  },
);
