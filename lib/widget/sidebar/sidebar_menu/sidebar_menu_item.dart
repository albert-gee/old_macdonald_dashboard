import 'package:flutter/material.dart';

/// A class representing a single item in the sidebar menu.
class SideMenuItem {
  /// The title of the menu item.
  final String title;

  /// The icon associated with the menu item.
  final IconData icon;

  /// Constructor for creating a [SideMenuItem].
  const SideMenuItem({
    required this.title,
    required this.icon,
  });
}
