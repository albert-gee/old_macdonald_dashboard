import 'package:flutter/material.dart';
import 'package:dashboard/widget/sidebar/sidebar_menu/sidebar_toggle_button_widget.dart';
import 'package:dashboard/widget/sidebar/sidebar_menu/sidebar_menu_item.dart';
import 'package:dashboard/widget/sidebar/sidebar_menu/sidebar_menu_widget.dart';

/// A widget that represents a sidebar. It includes a header with a title and
/// subtitle, a toggle button for collapsing/expanding the sidebar, and a menu.
class SidebarWidget extends StatelessWidget {
  /// Title displayed at the top of the sidebar.
  final String title;

  /// Subtitle displayed below the title in the sidebar.
  final String subTitle;

  /// Background color of the sidebar.
  final Color backgroundColor;

  /// Width of the sidebar, dynamically adjusted based on collapse state.
  final double width;

  /// Indicates whether the sidebar is in a collapsed state.
  final bool isCollapsed;

  /// List of menu items displayed in the sidebar.
  final List<SideMenuItem> menuItems;

  /// Index of the currently selected menu item.
  final int selectedIndex;

  /// Callback triggered when a menu item is selected.
  final ValueChanged<int> onItemSelected;

  /// Callback triggered when the collapse/expand button is toggled.
  final VoidCallback onToggleCollapse;

  /// Constructor for SidebarWidget.
  const SidebarWidget({
    super.key,
    required this.title,
    required this.subTitle,
    required this.backgroundColor,
    required this.width,
    required this.isCollapsed,
    required this.menuItems,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    // Access the current theme for consistent styling.
    final theme = Theme.of(context);

    return Container(
      width: width,
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Display toggle button when the sidebar is collapsed.
          if (isCollapsed)
            Center(
              child: SidebarToggleButtonWidget(
                isCollapsed: isCollapsed,
                onToggle: onToggleCollapse,
              ),
            )
          else
            // Display title and toggle button when the sidebar is expanded.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                  ),
                  SidebarToggleButtonWidget(
                    isCollapsed: isCollapsed,
                    onToggle: onToggleCollapse,
                  ),
                ],
              ),
            ),

          // Display subtitle when the sidebar is expanded.
          if (!isCollapsed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                subTitle,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[400],
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Horizontal Divider
          const Divider(
            color: Colors.white10,
            thickness: 1,
            height: 0,
          ),

          const SizedBox(height: 12),

          // Menu
          Expanded(
            child: SidebarMenuWidget(
              items: menuItems,
              selectedIndex: selectedIndex,
              isCollapsed: isCollapsed,
              onItemSelected: onItemSelected,
            ),
          ),
        ],
      ),
    );
  }
}
