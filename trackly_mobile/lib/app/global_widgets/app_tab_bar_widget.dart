import 'package:flutter/material.dart';
import 'package:trackly/app/core/extensions/context_extensions.dart';

import '../core/values/app_colors.dart';
import '../core/values/app_dimensions.dart';
import 'app_icon_widget.dart';
import 'app_text_widget.dart';

class AppTabBarWidget extends StatelessWidget {
  final List<AppTabBarItem> items;
  final int selectedIndex;
  final void Function(int index)? onTap;
  final bool isBottomIndicator;

  const AppTabBarWidget({
    super.key,
    required this.items,
    this.selectedIndex = 0,
    required this.onTap,
    this.isBottomIndicator = false,
  }) : assert(
         items.length >= 2 && items.length <= 6,
         'items.length must be between 2 and 6',
       ),
       assert(
         selectedIndex >= 0 && selectedIndex < items.length,
         'selectedIndex must be between 0 and ${items.length - 1}',
       );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.height60,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var index = 0; index < items.length; ++index)
              Expanded(
                child: _getItemWidget(
                  index: index,
                  item: items[index],
                  context: context,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _getItemWidget({
    required int index,
    required AppTabBarItem item,
    required BuildContext context,
  }) {
    final isSelected = index == selectedIndex;

    // Modern palette definition
    final activeColor = context.theme.primaryColor;
    final inactiveColor = AppColors
        .gray02; // Assuming gray02 represents your disabled/neutral tint

    // Swap icons based on selection state
    final displayIcon = (isSelected && item.activeIconData != null)
        ? item.activeIconData!
        : item.iconData!;

    return InkWell(
      onTap: () => onTap?.call(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (item.iconData != null)
            AppIconWidget(
              iconData: displayIcon,
              color: isSelected ? activeColor : inactiveColor,
              size: AppDimensions.iconSize24,
            ),
          const SizedBox(height: 4),
          if (item.text != null)
            AppTextWidget(
              text: item.text!,
              maxLines: 1,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: AppDimensions.fontSize12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }
}

class AppTabBarItem {
  final IconData? iconData;
  final IconData? activeIconData; // Added for filled style
  final String? text;

  const AppTabBarItem({
    this.iconData,
    this.activeIconData,
    this.text,
  }) : assert(
         iconData != null || text != null,
         'Must have icon or text',
       );
}
