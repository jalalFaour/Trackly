import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../login_controller.dart';
import '../ui/login_ui_state.dart';

final loginControllerProvider = NotifierProvider<LoginController, LoginUiState>(
  () {
    return LoginController();
  },
);
