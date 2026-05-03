import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/dashboard_destination.dart';
import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_page_header.dart';
import 'package:dashboard/src/features/matter/presentation/screens/matter_screen.dart';
import 'package:dashboard/src/features/orchestrator/presentation/screens/orchestrator_screen.dart';
import 'package:dashboard/src/features/orchestrator/presentation/widgets/websocket_connection_indicator.dart';
import 'package:dashboard/src/features/thread/presentation/screens/thread_screen.dart';
import 'package:dashboard/src/features/wifi/presentation/screens/wifi_ap_screen.dart';
import 'package:dashboard/src/features/wifi/presentation/screens/wifi_sta_screen.dart';

class DashboardShell extends ConsumerWidget {
  const DashboardShell({super.key});

  static final List<DashboardDestination> destinations = [
    DashboardDestination(
      title: 'Orchestrator',
      icon: Icons.hub,
      builder: (_) => const OrchestratorScreen(),
    ),
    DashboardDestination(
      title: 'Wi-Fi STA',
      icon: Icons.network_wifi,
      builder: (_) => const WifiStaScreen(),
    ),
    DashboardDestination(
      title: 'Wi-Fi AP',
      icon: Icons.wifi_tethering,
      builder: (_) => const WifiApScreen(),
    ),
    DashboardDestination(
      title: 'Thread Network',
      icon: Icons.lan,
      builder: (_) => const ThreadScreen(),
    ),
    DashboardDestination(
      title: 'Matter Network',
      icon: Icons.device_hub,
      builder: (_) => const MatterScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedDashboardDestinationProvider);
    final collapsed = ref.watch(sidebarCollapsedProvider);
    final config = ref.watch(appConfigProvider);
    final destination = destinations[selectedIndex];

    return Scaffold(
      body: Row(
        children: [
          _Sidebar(
            title: config.appTitle,
            subtitle: config.appSubtitle,
            collapsed: collapsed,
            selectedIndex: selectedIndex,
            onToggle: () =>
                ref.read(sidebarCollapsedProvider.notifier).state = !collapsed,
            onSelect: (index) => ref
                .read(selectedDashboardDestinationProvider.notifier)
                .state = index,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingPage),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppPageHeader(title: destination.title),
                  const SizedBox(height: AppDimensions.spacingL),
                  Expanded(child: destination.builder(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool collapsed;
  final int selectedIndex;
  final VoidCallback onToggle;
  final ValueChanged<int> onSelect;

  const _Sidebar({
    required this.title,
    required this.subtitle,
    required this.collapsed,
    required this.selectedIndex,
    required this.onToggle,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: collapsed
          ? AppDimensions.sidebarCollapsedWidth
          : AppDimensions.sidebarExpandedWidth,
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimensions.spacingM),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingM,
            ),
            child: Row(
              children: [
                if (!collapsed)
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                IconButton(
                  tooltip: collapsed ? 'Expand sidebar' : 'Collapse sidebar',
                  onPressed: onToggle,
                  icon: Icon(
                    collapsed ? Icons.chevron_right : Icons.chevron_left,
                  ),
                ),
              ],
            ),
          ),
          if (!collapsed)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingM,
                vertical: AppDimensions.spacingXS,
              ),
              child: Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: DashboardShell.destinations.length,
              itemBuilder: (context, index) {
                final destination = DashboardShell.destinations[index];
                final selected = index == selectedIndex;
                final foreground = selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface;
                return ListTile(
                  selected: selected,
                  leading: destination.title == 'Orchestrator'
                      ? const WebsocketConnectionIndicator()
                      : Icon(destination.icon, color: foreground),
                  title: collapsed
                      ? null
                      : Text(
                          destination.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                  onTap: () => onSelect(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
