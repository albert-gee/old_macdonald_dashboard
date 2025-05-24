import 'package:flutter/material.dart';
import 'package:dashboard/styles/app_dimensions.dart';

import 'package:dashboard/pages/main_page.dart';
import 'package:dashboard/pages/wifi_sta_page.dart';
import 'package:dashboard/pages/wifi_ap_page.dart';
import 'package:dashboard/pages/thread_page.dart';
import 'package:dashboard/pages/matter_page.dart';

import 'package:dashboard/widget/sidebar/sidebar_widget.dart';
import 'package:dashboard/widget/sidebar/sidebar_menu/sidebar_menu_item.dart';
import 'package:dashboard/widget/content/page_header.dart';

/// Main application layout with persistent sidebar navigation.
///
/// Displays the selected page alongside a collapsible sidebar.
class Layout extends StatefulWidget {
  final String title;
  final String subTitle;

  const Layout({
    super.key,
    required this.title,
    required this.subTitle,
  });

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int selectedIndex = 0;
  bool isCollapsed = false;

  /// Page titles used for the sidebar and header.
  final List<String> titles = [
    'Main Page',
    'Wi-Fi STA',
    'Wi-Fi AP',
    'Thread Network',
    'Matter Network',
  ];

  /// Sidebar menu items.
  late final List<SidebarMenuItem> menuItems = [
    SidebarMenuItem(icon: Icons.dashboard, title: titles[0]),
    SidebarMenuItem(icon: Icons.network_wifi, title: titles[1]),
    SidebarMenuItem(icon: Icons.wifi_tethering, title: titles[2]),
    SidebarMenuItem(icon: Icons.lan, title: titles[3]),
    SidebarMenuItem(icon: Icons.device_hub, title: titles[4]),
  ];

  /// Corresponding pages for each menu item.
  late final List<Widget> pages = [
    MainPage(),
    WifiStaPage(),
    WifiApPage(),
    ThreadPage(),
    MatterPage(),
  ];

  /// Handles menu item selection.
  void _onItemSelected(int index) {
    setState(() => selectedIndex = index);
  }

  /// Toggles sidebar collapsed state.
  void _onToggleCollapse() {
    setState(() => isCollapsed = !isCollapsed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SidebarWidget(
            title: widget.title,
            subTitle: widget.subTitle,
            isCollapsed: isCollapsed,
            menuItems: menuItems,
            selectedIndex: selectedIndex,
            onItemSelected: _onItemSelected,
            onToggleCollapse: _onToggleCollapse,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingPage),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageHeaderWidget(title: titles[selectedIndex]),
                  const SizedBox(height: AppDimensions.spacingL),
                  Expanded(
                    child: IndexedStack(
                      index: selectedIndex,
                      children: pages,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
