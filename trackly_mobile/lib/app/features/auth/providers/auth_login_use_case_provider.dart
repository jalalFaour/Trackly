import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../domain/use_cases/auth_login_use_case.dart';
import 'auth_repository_provider.dart';

final authLoginUseCaseProvider = Provider.autoDispose<AuthLoginUseCase>(
  (ref) {
    final authRepository = ref.read(
      authRepositoryProvider,
    );

    return AuthLoginUseCase(
      repository: authRepository,
    );
  },
);
