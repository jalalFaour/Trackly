import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackly/app/global_widgets/app_bar_widget.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../global_pages/error/app_base_page.dart';
import 'profile_content.dart';
import 'providers/profile_controller_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        ref.profileController.afterViewReady();
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return AppBasePage(
      content: Scaffold(
        appBar: AppBarWidget(
          title: context.localizations.profile,
          centerTitle: true,
        ),
        body: const ProfileContent(),
      ),
    );
  }
}
