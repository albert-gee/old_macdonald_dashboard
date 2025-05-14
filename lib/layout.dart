import 'package:dashboard/pages/websocket_page.dart';
import 'package:dashboard/widget/sidebar/sidebar_menu/sidebar_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/widget/sidebar/sidebar_widget.dart';

/// The main layout of the application.
///
/// This widget provides a two-column layout with a sidebar on the left
/// and a content area on the right. The sidebar allows navigation between
/// different sections of the application.
class Layout extends StatefulWidget {
  /// The title displayed in the sidebar header.
  final String title;

  /// The subtitle displayed in the sidebar header.
  final String subTitle;

  /// Creates a [Layout] widget.
  ///
  /// - [title] is the main title for the sidebar.
  /// - [subTitle] is the subtitle for the sidebar.
  const Layout({
    super.key,
    required this.title,
    required this.subTitle,
  });

  @override
  State<Layout> createState() => _LayoutState();
}

/// The state for the [Layout] widget.
///
/// Manages the selected menu item and the collapsed state of the sidebar.
class _LayoutState extends State<Layout> {
  /// The index of the currently selected menu item.
  int selectedIndex = 0;

  /// Indicates whether the sidebar is collapsed.
  bool isCollapsed = false;

  /// The list of menu items displayed in the sidebar.
  final List<SideMenuItem> menuItems = [
    SideMenuItem(icon: Icons.dashboard, title: 'Main Dashboard'),
    SideMenuItem(icon: Icons.network_wifi, title: 'Wi-Fi STA'),
    SideMenuItem(icon: Icons.wifi_tethering, title: 'Wi-Fi AP'),
    SideMenuItem(icon: Icons.lan, title: 'Thread Network'),
  ];

  /// The list of pages corresponding to each menu item.
  final List<Widget> pages = [
    WebsocketPage(
      title: "Main Dashboard",
    ),

    const Center(
      child: Text(
        'Wi-Fi STA',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),

    const Center(
      child: Text(
        'Wi-Fi AP',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),

    Container(
      color: Colors.green,
      child: const Center(
        child: Text(
          'Thread',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    ),
  ];

  /// Handles the selection of a menu item.
  ///
  /// Updates the [selectedIndex] to the index of the selected item.
  void _onItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  /// Toggles the collapsed state of the sidebar.
  void _onToggleCollapse() {
    setState(() {
      isCollapsed = !isCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sets the background color of the main layout.
      backgroundColor: const Color(0xff121212),
      body: Row(
        children: [
          // The sidebar widget.
          SidebarWidget(
            title: widget.title,
            subTitle: widget.subTitle,
            backgroundColor: Colors.grey.shade900,
            width: isCollapsed ? 60 : 200,
            isCollapsed: isCollapsed,
            menuItems: menuItems,
            selectedIndex: selectedIndex,
            onItemSelected: _onItemSelected,
            onToggleCollapse: _onToggleCollapse,
          ),
          // The content area that displays the selected section.
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xff1e1e1e),
                    Color(0xff2c2c2c),
                  ],
                ),
              ),
              child: IndexedStack(
                index: selectedIndex,
                children: pages,
              ),
            ),
          )
        ],
      ),
    );
  }
}


// Widget _buildMainSection(BuildContext context) {
  //   return Container(
  //     decoration: const BoxDecoration(
  //       gradient: LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [
  //           Color(0xff1e1e1e),
  //           Color(0xff2c2c2c),
  //         ],
  //       ),
  //     ),
  //     child: CustomScrollView(
  //       slivers: [
  //         SliverPadding(
  //           padding: const EdgeInsets.all(20.0),
  //           sliver: SliverList(
  //             delegate: SliverChildListDelegate([
  //               // Header
  //               _buildHeader(context),
  //               const SizedBox(height: 20.0),
  //
  //               // Message Log
  //               const SizedBox(
  //                 height: 150,
  //                 child: MessageLogWidget(),
  //               ),
  //               const SizedBox(height: 20.0),
  //
  //               // Dashboard
  //               const DashboardWidget(),
  //             ]),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  // Widget _buildHeader(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: <Widget>[
  //       Text(
  //         title,
  //         style: const TextStyle(
  //           fontSize: 36.0,
  //           fontWeight: FontWeight.bold,
  //           color: Colors.white,
  //           shadows: [
  //             Shadow(
  //               blurRadius: 10.0,
  //               color: Colors.lightBlueAccent,
  //             ),
  //           ],
  //         ),
  //       ),
  //       Text(
  //         subTitle,
  //         style: const TextStyle(
  //           fontSize: 16,
  //           color: Colors.white70,
  //         ),
  //       ),
  //     ],
  //   );
  // }
// }
