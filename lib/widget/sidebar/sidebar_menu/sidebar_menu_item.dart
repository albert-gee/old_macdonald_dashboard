import 'package:flutter/material.dart';

/// A class representing a single item in the sidebar menu.
class SidebarMenuItem {
  /// The title of the menu item.
  final String title;

  /// The icon associated with the menu item.
  final IconData icon;

  /// Constructor for creating a [SidebarMenuItem].
  const SidebarMenuItem({
    required this.title,
    required this.icon,
  });
}
