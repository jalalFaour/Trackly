import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/services/profile_service.dart';

final profileServiceProvider = Provider<ProfileService>(
  (ref) {
    return ProfileService.getInstance(
      ref: ref,
    );
  },
);
