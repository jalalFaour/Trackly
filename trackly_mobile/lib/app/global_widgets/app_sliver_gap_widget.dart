import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../core/values/app_dimensions.dart';

class AppSliverGapWidget extends StatelessWidget {
  final double mainAxisExtent;
  final double? crossAxisExtent;
  final Color? color;

  const AppSliverGapWidget({
    super.key,
    this.mainAxisExtent = AppDimensions.paddingOrMargin08,
    this.crossAxisExtent,
    this.color,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SliverToBoxAdapter(
      child: Gap(
        mainAxisExtent,
        color: color,
        crossAxisExtent: crossAxisExtent,
      ),
    );
  }
}
