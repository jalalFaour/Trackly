import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

import 'package:trackly/app/features/profile/presentation/profile/profile_page.dart';
import 'package:trackly/app/core/extensions/context_extensions.dart';
import 'package:trackly/app/features/tracking/presentation/tracking/tracking_page.dart';
import 'package:trackly/app/global_widgets/app_tab_bar_widget.dart';
import 'package:trackly/app/routing/app_router_routes.dart';

import '../../mapRoutes/presentation/map_routes/map_routes_page.dart';
import '../../wallet/presentation/wallet/wallet_page.dart';

// ... imports remain the same ...

class NavPage extends StatefulWidget {
  final String subPage;
  final String? routeId;

  const NavPage({
    super.key,
    required this.subPage,
    this.routeId,
  });

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  static const List<String> _subPageIds = [
    'Map',
    'Routes',
    'Wallet',
    'Profile',
  ];

  int get _selectedIndex {
    final index = _subPageIds.indexOf(widget.subPage);
    return index >= 0 ? index : 0;
  }

  Widget _pageForIndex(int index) {
    switch (index) {
      case 0:
        return TrackingPage(
          key: ValueKey<String?>(widget.routeId),
          initialRouteId: widget.routeId,
        );
      case 1:
        return const MapRoutesPage();
      case 2:
        return const WalletPage();
      case 3:
        return const ProfilePage();
      default:
        return TrackingPage(
          key: ValueKey<String?>(widget.routeId),
          initialRouteId: widget.routeId,
        );
    }
  }

  List<AppTabBarItem> _items(BuildContext context) => [
    AppTabBarItem(
      iconData: MdiIcons.mapOutline,
      activeIconData: MdiIcons.map, // Filled variant
      text: context.localizations.map,
    ),
    AppTabBarItem(
      iconData: MdiIcons.directionsFork,
      activeIconData: MdiIcons
          .directionsFork, // Mdi directionsFork is typically filled/static
      text: context.localizations.routes,
    ),
    AppTabBarItem(
      iconData: MdiIcons.walletOutline,
      activeIconData: MdiIcons.wallet, // Filled variant
      text: context.localizations.wallet,
    ),
    AppTabBarItem(
      iconData: MdiIcons.accountOutline,
      activeIconData: MdiIcons.account, // Filled variant
      text: context.localizations.profile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageForIndex(_selectedIndex.clamp(0, 3)),
      bottomNavigationBar: AppTabBarWidget(
        items: _items(context),
        selectedIndex: _selectedIndex,
        onTap: (int index) {
          final targetSubPage = _subPageIds[index];
          context.goNamed(
            AppRouterEnum.nav.name,
            pathParameters: {
              AppRouterKeys.subPage: targetSubPage,
            },
          );
        },
        isBottomIndicator: false,
      ),
    );
  }
}
