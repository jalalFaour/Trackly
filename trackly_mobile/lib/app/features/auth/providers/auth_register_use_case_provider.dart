import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../domain/use_cases/auth_register_use_case.dart';
import 'auth_repository_provider.dart';

final authRegisterUseCaseProvider = Provider.autoDispose<AuthRegisterUseCase>(
  (ref) {
    final authRepository = ref.read(
      authRepositoryProvider,
    );

    return AuthRegisterUseCase(
      repository: authRepository,
    );
  },
);
