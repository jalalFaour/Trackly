import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>(
  (ref) {
    return AuthService.getInstance(
      ref: ref,
    );
  },
);
