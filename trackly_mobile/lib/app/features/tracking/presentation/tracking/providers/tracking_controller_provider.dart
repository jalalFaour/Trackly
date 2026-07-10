import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ui/tracking_ui_state.dart';
import '../tracking_controller.dart';


final trackingControllerProvider =
    NotifierProvider<TrackingController, TrackingUiState>(
      () {
        return TrackingController();
      },
    );

extension trackingControllerProviderWidgetRefExtension on WidgetRef {
  TrackingController get trackingController => read(
    trackingControllerProvider.notifier,
  );
}

extension trackingControllerProviderRefExtension on Ref {
  TrackingController get trackingController => read(
    trackingControllerProvider.notifier,
  );
}
