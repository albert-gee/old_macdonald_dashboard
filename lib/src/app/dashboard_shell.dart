import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/dashboard_destination.dart';
import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_page_header.dart';
import 'package:dashboard/src/features/chamber/presentation/screens/chamber_screen.dart';
import 'package:dashboard/src/features/developer/presentation/screens/developer_screen.dart';
import 'package:dashboard/src/features/devices/presentation/screens/devices_screen.dart';
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
      title: 'Chamber',
      icon: Icons.eco,
      builder: (_) => const ChamberScreen(),
    ),
    DashboardDestination(
      title: 'Devices',
      icon: Icons.sensors,
      builder: (_) => const DevicesScreen(),
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
    DashboardDestination(
      title: 'Developer',
      icon: Icons.terminal,
      builder: (_) => const DeveloperScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedDashboardDestinationProvider);
    final collapsed = ref.watch(sidebarCollapsedProvider);
    final config = ref.watch(appConfigProvider);
    final destination = destinations[selectedIndex];

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = math.max(constraints.maxWidth, 800.0);
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width,
              child: Row(
                children: [
                  _Sidebar(
                    title: config.appTitle,
                    subtitle: config.appSubtitle,
                    collapsed: collapsed,
                    selectedIndex: selectedIndex,
                    onToggle: () =>
                        ref.read(sidebarCollapsedProvider.notifier).state =
                            !collapsed,
                    onSelect: (index) =>
                        ref
                                .read(
                                  selectedDashboardDestinationProvider.notifier,
                                )
                                .state =
                            index,
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
            ),
          );
        },
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
      child: ListView(
        padding: EdgeInsets.zero,
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
          for (
            var index = 0;
            index < DashboardShell.destinations.length;
            index++
          )
            _DestinationTile(
              destination: DashboardShell.destinations[index],
              selected: index == selectedIndex,
              collapsed: collapsed,
              onTap: () => onSelect(index),
            ),
        ],
      ),
    );
  }
}

class _DestinationTile extends StatelessWidget {
  final DashboardDestination destination;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  const _DestinationTile({
    required this.destination,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          : Text(destination.title, overflow: TextOverflow.ellipsis),
      onTap: onTap,
    );
  }
}
