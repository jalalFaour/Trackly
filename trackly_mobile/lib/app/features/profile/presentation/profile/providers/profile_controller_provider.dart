import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../profile_controller.dart';
import '../ui/profile_ui_state.dart';

final profileControllerProvider =
    NotifierProvider.autoDispose<ProfileController, ProfileUiState>(
      () {
        return ProfileController();
      },
    );

extension ProfileControllerProviderWidgetRefExtension on WidgetRef {
  ProfileController get profileController => read(
    profileControllerProvider.notifier,
  );
}

extension ProfileControllerProviderRefExtension on Ref {
  ProfileController get profileController => read(
    profileControllerProvider.notifier,
  );
}
