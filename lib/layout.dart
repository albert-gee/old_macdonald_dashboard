import 'package:flutter/material.dart';
import 'package:dashboard/pages/websocket_page.dart';
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

  List<SideMenuItem> get menuItems => const [
    SideMenuItem(icon: Icons.dashboard, title: 'Main Dashboard'),
    SideMenuItem(icon: Icons.network_wifi, title: 'Wi-Fi STA'),
    SideMenuItem(icon: Icons.wifi_tethering, title: 'Wi-Fi AP'),
    SideMenuItem(icon: Icons.lan, title: 'Thread Network'),
  ];

  List<Widget> get pages => [
    WebsocketPage(title: 'Main Dashboard'),
    _buildPlaceholder('Wi-Fi STA'),
    _buildPlaceholder('Wi-Fi AP'),
    _buildPlaceholder('Thread'),
  ];

  Widget _buildPlaceholder(String label) => Center(
    child: Text(
      label,
      style: Theme.of(context).textTheme.bodyLarge,
    ),
  );

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
            child: IndexedStack(
              index: selectedIndex,
              children: pages,
            ),
          ),
        ],
      ),
    );
  }
}
