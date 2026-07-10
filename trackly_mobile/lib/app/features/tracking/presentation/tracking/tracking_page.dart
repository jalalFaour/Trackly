import 'package:flutter/material.dart';

import 'package:gap/gap.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:trackly/app/core/extensions/context_extensions.dart';

import 'package:trackly/app/core/values/app_colors.dart';

import 'package:trackly/app/core/values/app_dimensions.dart';

import 'package:trackly/app/global_pages/error/app_base_page.dart';

import 'package:trackly/app/global_pages/success/success_dialog.dart';

import 'package:trackly/app/global_widgets/app_icon_widget.dart';

import 'package:trackly/app/global_widgets/app_text_widget.dart';

import 'providers/tracking_controller_provider.dart';

import 'tracking_content.dart';

import 'ui/tracking_ui_state.dart';

class TrackingPage extends StatefulHookConsumerWidget {
  const TrackingPage({
    super.key,
    this.initialRouteId,
  });

  final String? initialRouteId;

  @override
  _TrackingPageState createState() => _TrackingPageState();
}

class _TrackingPageState extends ConsumerState<TrackingPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        ref.trackingController.afterViewReady(
          selectedRouteId: widget.initialRouteId,
        );
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final uiState = ref.watch(trackingControllerProvider);
    final hasUserLocation = uiState.userLocation != null;

    return AppBasePage<TrackingUiState>(
      baseControllerProvider: trackingControllerProvider,
      content: Scaffold(
        // Stack the two action buttons in the bottom-right corner,
        // Google Maps style: recenter on top, QR scanner below.
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _RecenterMyLocationFab(
              enabled: hasUserLocation,
              onPressed: hasUserLocation
                  ? () {
                      final mapState = trackingMapViewKey.currentState;
                      if (mapState == null) return;
                      // Call the public method we added on
                      // _TrackingMapViewState. Dynamic dispatch keeps
                      // the private State class out of the import.
                      (mapState as dynamic).recenterOnUser(
                        uiState.userLocation!,
                      );
                    }
                  : null,
            ),
            const Gap(AppDimensions.paddingOrMargin12),
            FloatingActionButton(
              heroTag: 'qr-scanner',
              onPressed: () => showQRScanner(context, ref),
              backgroundColor: context.theme.colorScheme.primary,
              foregroundColor: context.theme.colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radius16),
              ),
              child: const AppIconWidget(
                iconData: Icons.qr_code_2_outlined,
                size: AppDimensions.iconSize30,
                color: AppColors.white,
              ),
            ),
          ],
        ),
        body: TrackingContent(),
      ),
    );
  }

  void showQRScanner(BuildContext context, WidgetRef ref) {
    bool isProcessing = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        final uiState = ref.watch(trackingControllerProvider);

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingOrMargin16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const AppTextWidget(
                      text: 'Scan To Pay',
                      fontSize: AppDimensions.fontSize18,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.visible,
                    ),
                    const Gap(AppDimensions.paddingOrMargin08),
                    AppTextWidget(
                      text: 'The price is : ${uiState.deductPrice} SYP',
                      fontSize: AppDimensions.fontSize14,
                      fontWeight: FontWeight.normal,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: AppDimensions.width280,
                height: AppDimensions.height280,
                child: MobileScanner(
                  onDetect: (capture) {
                    if (isProcessing) return;

                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isEmpty) return;

                    final String? code = barcodes.first.rawValue;
                    if (code == null || code.isEmpty) return;

                    isProcessing = true;

                    ref.trackingController.payForTheBus(
                      busId: code,
                      onSuccess: () {
                        if (Navigator.of(dialogContext).canPop()) {
                          Navigator.pop(dialogContext, code);
                        }
                        if (!mounted) return;
                        showSuccessDialog(
                          context,
                          message: 'Payment successful!',
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppDimensions.paddingOrMargin16),
            ],
          ),
        );
      },
    ).then((result) {
      if (result != null) debugPrint('Scanned QR Code: $result');
    });
  }
}

class _RecenterMyLocationFab extends StatelessWidget {
  const _RecenterMyLocationFab({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;

    return Tooltip(
      message: enabled
          ? 'Recenter on my location'
          : 'Waiting for your location…',
      child: FloatingActionButton(
        heroTag: 'recenter-my-location',
        onPressed: onPressed,
        backgroundColor: enabled
            ? scheme.primary
            : scheme.surfaceContainerHighest,
        foregroundColor: enabled
            ? scheme.onPrimary
            : scheme.onSurface.withOpacity(0.4),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
        ),
        child: Icon(
          enabled ? Icons.my_location_rounded : Icons.location_disabled_rounded,
          size: AppDimensions.iconSize26,
        ),
      ),
    );
  }
}
