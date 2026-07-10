import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trackly/app/core/extensions/context_extensions.dart';
import 'package:trackly/app/features/mapRoutes/presentation/map_routes/providers/map_routes_controller_provider.dart';
import 'package:trackly/app/global_pages/error/app_base_page.dart';
import 'package:trackly/app/global_widgets/app_bar_widget.dart';

import 'map_routes_content.dart';
import 'ui/map_routes_ui_state.dart';

class MapRoutesPage extends ConsumerStatefulWidget {
  const MapRoutesPage({
    super.key,
  });
  @override
  _MapRoutesPageState createState() => _MapRoutesPageState();
}

class _MapRoutesPageState extends ConsumerState<MapRoutesPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        ref.mapRoutesController.afterViewReady();
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return AppBasePage<MapRoutesUiState>(
      baseControllerProvider: mapRoutesControllerProvider,
      content: Scaffold(
        appBar: AppBarWidget(
          title: context.localizations.routes,
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await ref.mapRoutesController.getroutes();
          },
          child: MapRoutesContent(),
        ),
      ),
    );
  }
}
