// lib/global/widgets/app_list_tile_widget.dart

import 'package:flutter/material.dart';

import '../core/values/app_dimensions.dart';

class AppListTileWidget extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final GestureTapCallback? onLongPress;
  final bool dense;
  final bool enabled;
  final EdgeInsetsGeometry? contentPadding;
  final ShapeBorder? shape;
  final Color? tileColor;
  final Color? selectedTileColor;
  final bool selected;
  final VisualDensity? visualDensity;
  final EdgeInsetsGeometry? horizontalTitleGap;
  final EdgeInsetsGeometry? minVerticalPadding;
  final EdgeInsetsGeometry? minLeadingWidth;

  const AppListTileWidget({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.dense = false,
    this.enabled = true,
    this.contentPadding,
    this.shape,
    this.tileColor,
    this.selectedTileColor,
    this.selected = false,
    this.visualDensity,
    this.horizontalTitleGap,
    this.minVerticalPadding,
    this.minLeadingWidth,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: enabled ? onTap : null,
      onLongPress: enabled ? onLongPress : null,
      dense: dense,
      enabled: enabled,
      contentPadding:
          contentPadding ??
          const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingOrMargin16,
            vertical: AppDimensions.paddingOrMargin08,
          ),
      shape: shape,
      tileColor: tileColor,
      selectedTileColor: selectedTileColor,
      selected: selected,
      visualDensity: visualDensity,
    );
  }
}
