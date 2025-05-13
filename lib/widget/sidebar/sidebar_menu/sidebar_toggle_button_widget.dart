import 'package:flutter/material.dart';

/// A toggle button for a sidebar. It allows the user to toggle the sidebar
/// between a collapsed and expanded state.
class SidebarToggleButtonWidget extends StatelessWidget {
  /// Indicates whether the sidebar is currently collapsed.
  final bool isCollapsed;

  /// Callback function that is triggered when the button is pressed.
  final VoidCallback onToggle;

  /// Constructor for SidebarToggleButtonWidget.
  const SidebarToggleButtonWidget({
    super.key,
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      // The button icon with an animated rotation effect.
      icon: AnimatedRotation(
        // Rotates the icon 180 degrees when the sidebar is collapsed.
        turns: isCollapsed ? 0.5 : 0,
        duration: const Duration(milliseconds: 200),
        child: const Icon(Icons.chevron_left),
      ),
      // Tooltip text that changes based on the sidebar state.
      tooltip: isCollapsed ? 'Expand menu' : 'Collapse menu',
      // Executes the provided callback when the button is pressed.
      onPressed: onToggle,
    );
  }
}
