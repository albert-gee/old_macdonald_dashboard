import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/dashboard_destination.dart';
import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/layout/app_empty_state.dart';
import 'package:dashboard/src/core/layout/app_page_scaffold.dart';
import 'package:dashboard/src/core/layout/app_responsive_grid.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_metric_tile.dart';
import 'package:dashboard/src/core/widgets/app_panel.dart';
import 'package:dashboard/src/features/chamber/presentation/widgets/chamber_relay_controls_card.dart';
import 'package:dashboard/src/features/chamber/presentation/widgets/chamber_sensor_cards.dart';

class ChamberScreen extends ConsumerStatefulWidget {
  const ChamberScreen({super.key});

  @override
  ConsumerState<ChamberScreen> createState() => _ChamberScreenState();
}

class _ChamberScreenState extends ConsumerState<ChamberScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(chamberControllerProvider.notifier).loadDevices(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chamberControllerProvider);
    final hasDevices = state.devices.isNotEmpty;
    final sensorCapabilities =
        state.temperatureOptions.length + state.pressureOptions.length;
    final actuatorCapabilities = state.relayOptions.length;
    final ready = sensorCapabilities > 0 || actuatorCapabilities > 0;

    return AppPageScaffold(
      title: 'Chamber Operations',
      description:
          'Monitor environmental readings and control registered chamber device functions.',
      children: [
        AppPanel(
          title: ready
              ? 'Chamber is ready for operation'
              : 'Chamber setup is incomplete',
          subtitle: ready
              ? 'Use the sections below for readings and actuator control.'
              : 'Register chamber devices and verify device capabilities before normal operation.',
          tone: ready ? AppPanelTone.success : AppPanelTone.warning,
          child: AppResponsiveGrid(
            children: [
              AppMetricTile(
                label: 'Registered devices',
                value: '${state.devices.length}',
                tone: hasDevices ? AppMetricTone.good : AppMetricTone.neutral,
              ),
              AppMetricTile(
                label: 'Environmental functions',
                value: '$sensorCapabilities',
                tone: sensorCapabilities > 0
                    ? AppMetricTone.good
                    : AppMetricTone.warning,
              ),
              AppMetricTile(
                label: 'Actuator functions',
                value: '$actuatorCapabilities',
                tone: actuatorCapabilities > 0
                    ? AppMetricTone.good
                    : AppMetricTone.neutral,
              ),
              AppMetricTile(
                label: 'Automation state',
                value: 'Unavailable',
                detail: 'Not exposed by current firmware.',
                tone: AppMetricTone.neutral,
              ),
            ],
          ),
        ),
        if (!hasDevices)
          AppEmptyState(
            icon: Icons.sensors_off,
            title: 'No chamber devices are registered yet.',
            explanation:
                'Devices appear here after commissioning and registry setup. Chamber controls need registered device capabilities.',
            recommendedAction:
                'Start with Matter Network, then verify Devices.',
            action: Wrap(
              spacing: AppDimensions.spacingM,
              children: [
                OutlinedButton(
                  onPressed: () => selectDashboardDestination(
                    ref,
                    DashboardDestinationKey.matter,
                  ),
                  child: const Text('Go to Matter Network'),
                ),
                OutlinedButton(
                  onPressed: () => selectDashboardDestination(
                    ref,
                    DashboardDestinationKey.devices,
                  ),
                  child: const Text('Go to Devices'),
                ),
              ],
            ),
          )
        else if (!ready)
          AppEmptyState(
            icon: Icons.extension_off,
            title: 'No usable device capabilities are registered.',
            explanation:
                'Registered devices need valid device capabilities before Chamber can read sensors or operate actuators.',
            recommendedAction:
                'Verify device capabilities on the Devices page.',
            action: OutlinedButton(
              onPressed: () => selectDashboardDestination(
                ref,
                DashboardDestinationKey.devices,
              ),
              child: const Text('Go to Devices'),
            ),
          ),
        const ChamberSensorCards(),
        const ChamberRelayControlsCard(),
      ],
    );
  }
}
