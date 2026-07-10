import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../splash_controller.dart';
import '../ui/splash_ui_state.dart';

final splashControllerProvider = NotifierProvider<SplashController, SplashUiState>(
  () {
    return SplashController();
  },
);
