import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/dashboard_destination.dart';
import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/layout/app_empty_state.dart';
import 'package:dashboard/src/core/layout/app_page_scaffold.dart';
import 'package:dashboard/src/core/layout/app_responsive_grid.dart';
import 'package:dashboard/src/core/widgets/app_metric_tile.dart';
import 'package:dashboard/src/core/widgets/app_panel.dart';
import 'package:dashboard/src/features/devices/presentation/widgets/device_list_card.dart';

class DevicesScreen extends ConsumerStatefulWidget {
  const DevicesScreen({super.key});

  @override
  ConsumerState<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends ConsumerState<DevicesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(deviceListControllerProvider.notifier).refresh(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deviceListControllerProvider);
    final devices = state.devices;
    final reachable = devices.where((device) => device.reachable).length;
    final withCapabilities = devices
        .where((device) => device.capabilities.isNotEmpty)
        .length;
    final withoutCapabilities = devices.length - withCapabilities;

    return AppPageScaffold(
      title: 'Device Registry',
      description:
          'Registered chamber devices and the device capabilities used by Chamber workflows.',
      children: [
        AppPanel(
          title: 'Registry overview',
          subtitle:
              'Commissioning makes a Matter node known; registry capabilities make it usable in chamber workflows.',
          child: AppResponsiveGrid(
            children: [
              AppMetricTile(
                label: 'Devices',
                value: '${devices.length}',
                tone: devices.isEmpty
                    ? AppMetricTone.neutral
                    : AppMetricTone.good,
              ),
              AppMetricTile(
                label: 'Reachable',
                value: '$reachable',
                tone: reachable > 0
                    ? AppMetricTone.good
                    : AppMetricTone.neutral,
              ),
              AppMetricTile(
                label: 'With capabilities',
                value: '$withCapabilities',
                tone: withCapabilities > 0
                    ? AppMetricTone.good
                    : AppMetricTone.warning,
              ),
              AppMetricTile(
                label: 'Missing capabilities',
                value: '$withoutCapabilities',
                tone: withoutCapabilities > 0
                    ? AppMetricTone.warning
                    : AppMetricTone.neutral,
              ),
            ],
          ),
        ),
        if (devices.isEmpty && !state.loading)
          AppEmptyState(
            icon: Icons.sensors_off,
            title: 'No chamber devices are registered.',
            explanation:
                'Devices appear after commissioning and registration. Pair a chamber device, then verify its device capabilities here.',
            recommendedAction: 'Go to Matter Network to start onboarding.',
            action: OutlinedButton(
              onPressed: () => selectDashboardDestination(
                ref,
                DashboardDestinationKey.matter,
              ),
              child: const Text('Go to Matter Network'),
            ),
          ),
        const DeviceListCard(),
      ],
    );
  }
}
