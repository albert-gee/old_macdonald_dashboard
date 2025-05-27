import 'package:flutter/material.dart';

/// A class representing a single item in the sidebar menu.
class SidebarMenuItem {

  /// The icon widget associated with the menu item.
  final Widget icon;

  /// The title of the menu item.
  final String title;

  /// Constructor for creating a [SidebarMenuItem].
  const SidebarMenuItem({
    required this.icon,
    required this.title,
  });
}
