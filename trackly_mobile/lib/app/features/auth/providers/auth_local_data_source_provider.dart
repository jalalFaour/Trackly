import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/data_sources/auth_local_data_source.dart';

final authLocalDataSourceProvider = Provider.autoDispose<AuthLocalDataSource>(
  (ref) {
    return AuthLocalDataSourceImpl();
  },
);
