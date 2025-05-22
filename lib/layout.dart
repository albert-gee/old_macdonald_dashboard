import 'package:dashboard/pages/matter_page.dart';
import 'package:dashboard/pages/thread_page.dart';
import 'package:dashboard/pages/wifi_ap_page.dart';
import 'package:dashboard/pages/wifi_sta_page.dart';
import 'package:dashboard/styles/app_dimensions.dart';
import 'package:dashboard/widget/content/page_header.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/pages/main_page.dart';
import 'package:dashboard/widget/sidebar/sidebar_widget.dart';
import 'package:dashboard/widget/sidebar/sidebar_menu/sidebar_menu_item.dart';

/// Main application layout with sidebar navigation.
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

  List<String> get titles => [
        'Main Page',
        'Wi-Fi STA',
        'Wi-Fi AP',
        'Thread Network',
        'Matter Network'
      ];

  List<SideMenuItem> get menuItems => [
        SideMenuItem(icon: Icons.dashboard, title: titles[0]),
        SideMenuItem(icon: Icons.network_wifi, title: titles[1]),
        SideMenuItem(icon: Icons.wifi_tethering, title: titles[2]),
        SideMenuItem(icon: Icons.lan, title: titles[3]),
        SideMenuItem(icon: Icons.device_hub, title: titles[4]),
      ];

  List<Widget> get pages =>
      [MainPage(), WifiStaPage(), WifiApPage(), ThreadPage(), MatterPage()];

  void _onItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void _onToggleCollapse() {
    setState(() {
      isCollapsed = !isCollapsed;
    });
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
                  const SizedBox(height: AppDimensions.spacingM),
                  PageHeaderWidget(title: titles[selectedIndex]),
                  const SizedBox(height: AppDimensions.spacingM),
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
