import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../map_routes_controller.dart';
import '../ui/map_routes_ui_state.dart';


final mapRoutesControllerProvider =
    NotifierProvider<MapRoutesController, MapRoutesUiState>(
      () {
        return MapRoutesController();
      },
    );

extension mapRoutesControllerProviderWidgetRefExtension on WidgetRef {
  MapRoutesController get mapRoutesController => read(
    mapRoutesControllerProvider.notifier,
  );
}

extension mapRoutesControllerProviderRefExtension on Ref {
  MapRoutesController get mapRoutesController => read(
    mapRoutesControllerProvider.notifier,
  );
}
