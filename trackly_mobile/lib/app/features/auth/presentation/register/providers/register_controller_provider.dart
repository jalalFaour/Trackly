import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../register_controller.dart';
import '../ui/register_ui_state.dart';

final registerControllerProvider = NotifierProvider<RegisterController, RegisterUiState>(
  () {
    return RegisterController();
  },
);
