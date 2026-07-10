import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'api_caller.dart';

final apiCallerProvider = Provider<ApiCaller>(
  (ref) {
    final dio = ref.watch(
      dioProvider,
    );

    return ApiCaller.getInstance(
      ref: ref,
      dio: dio,
    );
  },
);
