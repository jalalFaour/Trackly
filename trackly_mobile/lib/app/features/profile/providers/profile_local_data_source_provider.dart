import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/data_sources/profile_local_data_source.dart';

final profileLocalDataSourceProvider = Provider.autoDispose<ProfileLocalDataSource>(
  (ref) {
    return ProfileLocalDataSourceImpl();
  },
);
