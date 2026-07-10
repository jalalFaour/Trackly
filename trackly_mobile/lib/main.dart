import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:location/location.dart';

import 'app.dart';
import 'app/core/storage/app_storage.dart';

Future<void> main() async {
  // To remove # from URL path in  WEB
  usePathUrlStrategy();

  await AppStorage.getInstance().init();

  runApp(
    ProviderScope(
      child: const _TracklyBootstrap(),
    ),
  );
}

class _TracklyBootstrap extends StatefulWidget {
  const _TracklyBootstrap();

  @override
  State<_TracklyBootstrap> createState() => _TracklyBootstrapState();
}

class _TracklyBootstrapState extends State<_TracklyBootstrap> {
  late final Future<void> _bootstrapFuture;

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    var permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return FutureBuilder<void>(
      future: _bootstrapFuture,
      builder: (context, snapshot,
      ) {
        return const App();
      },
    );
  }
}
