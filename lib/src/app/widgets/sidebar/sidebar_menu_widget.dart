import 'package:flutter/material.dart';
import 'sidebar_menu_item.dart';

/// A widget that represents a sidebar menu.
///
/// The sidebar menu displays a list of menu items, allowing the user to select
/// one of them, and highlights the currently selected item. It supports both
/// collapsed and expanded sidebar states.
class SidebarMenuWidget extends StatelessWidget {
  /// The list of menu items to display in the sidebar.
  final List<SidebarMenuItem> items;

  /// The index of the currently selected menu item.
  final int selectedIndex;

  /// Indicates whether the sidebar is in a collapsed state.
  final bool isCollapsed;

  /// Callback function triggered when a menu item is selected.
  ///
  /// The callback receives the index of the selected item.
  final ValueChanged<int> onItemSelected;

  /// Creates a [SidebarMenuWidget].
  ///
  /// - [items] is the list of menu items to display.
  /// - [selectedIndex] is the index of the currently selected item.
  /// - [isCollapsed] determines whether the sidebar is collapsed.
  /// - [onItemSelected] is the callback function triggered on item selection.
  const SidebarMenuWidget({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.isCollapsed,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      // Removes padding around the list.
      padding: EdgeInsets.zero,
      // The number of items in the list.
      itemCount: items.length,
      // Builds each menu item in the list.
      itemBuilder: (_, index) {
        final item = items[index];
        final selected = index == selectedIndex;

        return Tooltip(
          // Displays a tooltip with the item's title when hovered.
          message: item.title,
          waitDuration: const Duration(milliseconds: 400),
          child: ListTile(
            // Reduces the vertical padding of the tile.
            dense: true,
            // Sets the horizontal padding of the tile.
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            // Displays the item's icon.
            leading: SizedBox(
              width: 24,
              child: item.icon,
            ),
            // Displays the item's title if the sidebar is not collapsed.
            title: isCollapsed
                ? null
                : Text(
                    item.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      // Changes the text color based on selection state.
                      color: selected ? Colors.white : Colors.grey[300],
                    ),
                  ),
            // Highlights the tile if it is selected.
            selected: selected,
            selectedTileColor: Colors.blue.shade700,
            // Triggers the callback when the tile is tapped.
            onTap: () => onItemSelected(index),
          ),
        );
      },
    );
  }
}
