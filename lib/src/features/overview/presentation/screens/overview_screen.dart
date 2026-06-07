import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/dashboard_destination.dart';
import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/layout/app_page_scaffold.dart';
import 'package:dashboard/src/core/layout/app_responsive_grid.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/theme/app_text_styles.dart';
import 'package:dashboard/src/core/widgets/app_metric_tile.dart';
import 'package:dashboard/src/core/widgets/app_panel.dart';
import 'package:dashboard/src/features/overview/domain/operator_runtime.dart';

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runtime = ref.watch(operatorRuntimeProvider);

    return AppPageScaffold(
      title: 'Overview',
      description:
          'Connection-first operating view for chamber setup, device readiness, and automation state.',
      children: [
        AppResponsiveGrid(
          minTileWidth: 300,
          children: [
            _ConnectionSummary(runtime: runtime),
            _OrchestratorSummary(runtime: runtime),
            _NextActionCard(runtime: runtime),
          ],
        ),
        AppPanel(
          title: 'Infrastructure status',
          subtitle:
              'The chamber workflow depends on WSS, Thread, and Matter being ready in order.',
          leading: const Icon(Icons.account_tree_outlined),
          tone: runtime.matterPlatformFailed
              ? AppPanelTone.critical
              : AppPanelTone.info,
          child: AppResponsiveGrid(
            children: [
              AppMetricTile(
                label: 'Wi-Fi AP',
                value: runtime.wifiApRunning ? 'Running' : 'Unknown',
                detail: runtime.snapshotReceived
                    ? 'Host endpoint ${runtime.endpoint}'
                    : 'Waiting for state_snapshot.',
                tone: runtime.wifiApRunning
                    ? AppMetricTone.good
                    : AppMetricTone.neutral,
              ),
              AppMetricTile(
                label: 'Thread',
                value: _threadValue(runtime),
                detail: runtime.threadDatasetPresent
                    ? 'Role ${runtime.threadRole}, attached ${runtime.threadAttached}'
                    : 'Active dataset is missing or not reported.',
                tone: _threadTone(runtime),
              ),
              AppMetricTile(
                label: 'Matter',
                value: _matterValue(runtime),
                detail:
                    runtime.matterPlatformError ??
                    (runtime.matterControllerInitialized
                        ? 'Controller ready.'
                        : 'Controller not initialized.'),
                tone: _matterTone(runtime),
              ),
              AppMetricTile(
                label: 'Devices',
                value: '${runtime.deviceCount}',
                detail:
                    '${runtime.commissionedNodeCount} commissioned nodes reported.',
                tone: runtime.deviceCount > 0
                    ? AppMetricTone.good
                    : AppMetricTone.neutral,
              ),
            ],
          ),
        ),
        AppPanel(
          title: 'Chamber state',
          subtitle:
              'Live readings, actuator state, and automation readiness from the latest snapshot and events.',
          leading: const Icon(Icons.eco_outlined),
          tone:
              runtime.chamberHasTemperatureAssignment &&
                  runtime.chamberHasActuatorAssignment
              ? AppPanelTone.success
              : AppPanelTone.warning,
          child: AppResponsiveGrid(
            children: [
              AppMetricTile(
                label: 'Temperature',
                value: runtime.chamber.temperature.value == null
                    ? 'No reading'
                    : '${runtime.chamber.temperature.value} C',
                detail: runtime.chamberHasTemperatureAssignment
                    ? 'Temperature source assigned.'
                    : 'Assign a temperature capability.',
                tone: runtime.chamber.temperature.value == null
                    ? AppMetricTone.neutral
                    : AppMetricTone.good,
              ),
              AppMetricTile(
                label: 'Pressure',
                value: runtime.chamber.pressure.value == null
                    ? 'Optional'
                    : '${runtime.chamber.pressure.value} kPa',
                detail: runtime.chamber.selectedPressure == null
                    ? 'Pressure source is optional.'
                    : 'Pressure source assigned.',
                tone: runtime.chamber.pressure.value == null
                    ? AppMetricTone.neutral
                    : AppMetricTone.good,
              ),
              AppMetricTile(
                label: 'Fan / relay',
                value: runtime.chamber.relay.lastCommandedOn == null
                    ? 'Unknown'
                    : runtime.chamber.relay.lastCommandedOn!
                    ? 'On'
                    : 'Off',
                detail: runtime.chamberHasActuatorAssignment
                    ? 'Actuator assigned.'
                    : 'Assign an On/Off actuator.',
                tone: runtime.chamberHasActuatorAssignment
                    ? AppMetricTone.good
                    : AppMetricTone.warning,
              ),
              AppMetricTile(
                label: 'Automation',
                value: runtime.controlEnabled
                    ? titleCase(runtime.controlState)
                    : 'Disabled',
                detail: runtime.controlRuleConfigured
                    ? 'Cooling rule configured.'
                    : 'Cooling rule not configured.',
                tone: runtime.controlEnabled
                    ? AppMetricTone.good
                    : AppMetricTone.neutral,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _threadValue(OperatorRuntime runtime) {
    if (!runtime.threadDatasetPresent) return 'Dataset missing';
    if (!runtime.threadEnabled) return 'Disabled';
    return runtime.threadAttached ? 'Attached' : 'Detached';
  }

  AppMetricTone _threadTone(OperatorRuntime runtime) {
    if (!runtime.threadDatasetPresent) return AppMetricTone.warning;
    if (!runtime.threadEnabled || !runtime.threadAttached) {
      return AppMetricTone.pending;
    }
    return AppMetricTone.good;
  }

  String _matterValue(OperatorRuntime runtime) {
    if (runtime.matterPlatformFailed) return 'Platform failed';
    if (runtime.matterControllerInitialized) return 'Controller ready';
    return 'Controller offline';
  }

  AppMetricTone _matterTone(OperatorRuntime runtime) {
    if (runtime.matterPlatformFailed) return AppMetricTone.critical;
    if (runtime.matterControllerInitialized) return AppMetricTone.good;
    return AppMetricTone.warning;
  }
}

class _ConnectionSummary extends StatelessWidget {
  final OperatorRuntime runtime;

  const _ConnectionSummary({required this.runtime});

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      title: 'Connection',
      subtitle: runtime.connected
          ? 'WSS is connected to the Orchestrator.'
          : 'Connect before using live controls.',
      leading: Icon(runtime.connected ? Icons.link : Icons.link_off),
      tone: runtime.connected ? AppPanelTone.success : AppPanelTone.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppMetricTile(
            label: 'State',
            value: runtime.connection.status.name,
            detail: runtime.endpoint,
            tone: runtime.connected
                ? AppMetricTone.good
                : AppMetricTone.warning,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            runtime.connected
                ? 'Last snapshot: ${ageLabel(runtime.lastSnapshotAt)}'
                : '1. Connect this host to the Orchestrator Wi-Fi AP.\n2. Confirm 192.168.4.1 is reachable.\n3. Press Connect in the top bar.',
            style: AppTextStyles.mutedBody,
          ),
        ],
      ),
    );
  }
}

class _OrchestratorSummary extends StatelessWidget {
  final OperatorRuntime runtime;

  const _OrchestratorSummary({required this.runtime});

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      title: 'Orchestrator health',
      subtitle: runtime.snapshotReceived
          ? 'Runtime snapshot received.'
          : 'No state_snapshot received yet.',
      leading: const Icon(Icons.memory_outlined),
      tone: runtime.matterPlatformFailed
          ? AppPanelTone.critical
          : runtime.snapshotReceived
          ? AppPanelTone.success
          : AppPanelTone.neutral,
      child: AppResponsiveGrid(
        minTileWidth: 130,
        children: [
          AppMetricTile(
            label: 'Snapshot',
            value: ageLabel(runtime.lastSnapshotAt),
            tone: runtime.snapshotReceived
                ? AppMetricTone.good
                : AppMetricTone.neutral,
            compact: true,
          ),
          AppMetricTile(
            label: 'WSS clients',
            value: '${runtime.websocketClients}',
            tone: runtime.connected
                ? AppMetricTone.info
                : AppMetricTone.neutral,
            compact: true,
          ),
        ],
      ),
    );
  }
}

class _NextActionCard extends ConsumerWidget {
  final OperatorRuntime runtime;

  const _NextActionCard({required this.runtime});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next = runtime.nextAction;
    return AppPanel(
      title: 'Next action',
      subtitle: next.detail,
      leading: const Icon(Icons.flag_outlined),
      tone: _tone(next.target),
      trailing: _button(ref, next),
      child: Text(next.title, style: AppTextStyles.sectionTitle),
    );
  }

  Widget? _button(WidgetRef ref, OperatorNextAction next) {
    final destination = switch (next.target) {
      OperatorNextActionTarget.connect => null,
      OperatorNextActionTarget.diagnostics =>
        DashboardDestinationKey.diagnostics,
      OperatorNextActionTarget.setup => DashboardDestinationKey.setup,
      OperatorNextActionTarget.devices => DashboardDestinationKey.devices,
      OperatorNextActionTarget.chamber => DashboardDestinationKey.chamber,
      OperatorNextActionTarget.ready => DashboardDestinationKey.chamber,
    };
    if (destination == null) return null;
    return FilledButton.icon(
      onPressed: () => selectDashboardDestination(ref, destination),
      icon: const Icon(Icons.arrow_forward),
      label: const Text('Open'),
    );
  }

  AppPanelTone _tone(OperatorNextActionTarget target) {
    return switch (target) {
      OperatorNextActionTarget.diagnostics => AppPanelTone.critical,
      OperatorNextActionTarget.ready => AppPanelTone.success,
      OperatorNextActionTarget.connect => AppPanelTone.warning,
      _ => AppPanelTone.info,
    };
  }
}
