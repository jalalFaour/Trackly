import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trackly/app/features/profile/domain/use_cases/profile_getUser_use_case.dart';

import 'profile_repository_provider.dart';

final profileGetUserUseCaseProvider =
    Provider.autoDispose<ProfileGetuserUseCase>(
      (ref) {
        final profileRepository = ref.read(
          profileRepositoryProvider,
        );

        return ProfileGetuserUseCase(
          repository: profileRepository,
        );
      },
    );
