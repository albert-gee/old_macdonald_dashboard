import 'package:dashboard/styles/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/widget/sidebar/sidebar_menu/sidebar_toggle_button_widget.dart';
import 'package:dashboard/widget/sidebar/sidebar_menu/sidebar_menu_item.dart';
import 'package:dashboard/widget/sidebar/sidebar_menu/sidebar_menu_widget.dart';

/// Sidebar with title, subtitle, toggle button, and navigation menu.
class SidebarWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final bool isCollapsed;
  final List<SideMenuItem> menuItems;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onToggleCollapse;

  const SidebarWidget({
    super.key,
    required this.title,
    required this.subTitle,
    required this.isCollapsed,
    required this.menuItems,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: isCollapsed
          ? AppDimensions.sidebarCollapsedWidth
          : AppDimensions.sidebarExpandedWidth,
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _buildHeader(theme),
          if (!isCollapsed) _buildSubtitle(theme),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          _buildMenu(),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    if (isCollapsed) {
      return Center(
        child: SidebarToggleButtonWidget(
          isCollapsed: isCollapsed,
          onToggle: onToggleCollapse,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium,
            ),
          ),
          SidebarToggleButtonWidget(
            isCollapsed: isCollapsed,
            onToggle: onToggleCollapse,
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Text(
        subTitle,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall,
      ),
    );
  }

  Widget _buildMenu() {
    return Expanded(
      child: SidebarMenuWidget(
        items: menuItems,
        selectedIndex: selectedIndex,
        isCollapsed: isCollapsed,
        onItemSelected: onItemSelected,
      ),
    );
  }
}
