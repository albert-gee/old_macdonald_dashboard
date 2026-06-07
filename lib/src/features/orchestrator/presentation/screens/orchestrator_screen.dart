import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/layout/app_page_scaffold.dart';
import 'package:dashboard/src/core/layout/app_responsive_grid.dart';
import 'package:dashboard/src/core/layout/app_section.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_status.dart';
import 'package:dashboard/src/core/widgets/app_metric_tile.dart';
import 'package:dashboard/src/core/widgets/app_panel.dart';
import 'package:dashboard/src/features/orchestrator/presentation/widgets/orchestrator_certificate_trust_card.dart';
import 'package:dashboard/src/features/orchestrator/presentation/widgets/orchestrator_pending_commands_card.dart';
import 'package:dashboard/src/features/orchestrator/presentation/widgets/orchestrator_recent_events_card.dart';
import 'package:dashboard/src/features/orchestrator/presentation/widgets/orchestrator_runtime_snapshot_card.dart';
import 'package:dashboard/src/features/orchestrator/presentation/widgets/websocket_connection_form.dart';

class OrchestratorScreen extends ConsumerWidget {
  const OrchestratorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(orchestratorConnectionControllerProvider);
    final runtime = ref.watch(orchestratorRuntimeControllerProvider);
    final devices = ref.watch(deviceListControllerProvider).devices;
    final connected = connection.status == WebSocketConnectionStatus.connected;
    final snapshotReceived = runtime.snapshot != null;
    final snapshot = runtime.snapshot;
    final trusted = connection.trustedFingerprint != null;
    final wifiAvailable =
        snapshot?.wifi.apRunning == true || snapshot?.wifi.staConnected == true;
    final threadReady =
        snapshot?.thread.enabled == true &&
        snapshot?.thread.datasetPresent == true &&
        snapshot?.thread.attached == true;
    final matterReady = snapshot?.matter.controllerInitialized == true;
    final devicesAvailable = devices.isNotEmpty;

    return AppPageScaffold(
      title: 'System Connection & Trust',
      description:
          'Connection, certificate trust, and runtime state for the Orchestrator.',
      children: [
        AppPanel(
          title: connected
              ? 'Dashboard is connected to the Orchestrator'
              : 'Dashboard is not connected to the Orchestrator',
          subtitle: connected
              ? 'Live chamber controls can use the active Orchestrator connection.'
              : 'Connect and trust the Orchestrator before using live controls.',
          tone: connected ? AppPanelTone.success : AppPanelTone.neutral,
          child: AppResponsiveGrid(
            children: [
              AppMetricTile(
                label: 'Connection',
                value: connection.status.name,
                tone: connected ? AppMetricTone.good : AppMetricTone.neutral,
              ),
              AppMetricTile(
                label: 'Certificate trust',
                value: trusted ? 'Trusted' : 'Not trusted',
                tone: trusted ? AppMetricTone.good : AppMetricTone.warning,
              ),
              AppMetricTile(
                label: 'Runtime state',
                value: snapshotReceived ? 'Snapshot received' : 'Waiting',
                tone: snapshotReceived
                    ? AppMetricTone.good
                    : AppMetricTone.pending,
              ),
              AppMetricTile(
                label: 'Connection URL',
                value: connection.url,
                tone: AppMetricTone.info,
              ),
            ],
          ),
        ),
        AppSection(
          title: 'Setup checklist',
          description:
              'Use this to understand what is required before normal chamber operation.',
          children: [
            AppPanel(
              title: 'Operator readiness',
              tone: connected && trusted && snapshotReceived
                  ? AppPanelTone.success
                  : AppPanelTone.warning,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ChecklistRow(
                    label: 'Connect to Orchestrator',
                    complete: connected,
                  ),
                  _ChecklistRow(
                    label: 'Trust Orchestrator certificate',
                    complete: trusted,
                  ),
                  _ChecklistRow(
                    label: 'Receive runtime snapshot',
                    complete: snapshotReceived,
                  ),
                  _ChecklistRow(
                    label: 'Confirm Wi-Fi access path',
                    complete: wifiAvailable,
                    unavailable: !snapshotReceived,
                  ),
                  _ChecklistRow(
                    label: 'Confirm Thread mesh readiness',
                    complete: threadReady,
                    unavailable: !snapshotReceived,
                  ),
                  _ChecklistRow(
                    label: 'Confirm Matter controller readiness',
                    complete: matterReady,
                    unavailable: !snapshotReceived,
                  ),
                  _ChecklistRow(
                    label: 'Load device registry',
                    complete: devicesAvailable,
                    unavailable: !snapshotReceived,
                  ),
                ],
              ),
            ),
          ],
        ),
        const OrchestratorCertificateTrustCard(),
        AppPanel(
          title: 'Connection settings',
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('WebSocket URL editor'),
            subtitle: const Text(
              'Use this when changing the Orchestrator connection URL.',
            ),
            children: const [
              SizedBox(height: AppDimensions.spacingM),
              WebsocketConnectionForm(),
            ],
          ),
        ),
        const AppPanel(
          title: 'Advanced diagnostics',
          subtitle:
              'Raw runtime state, pending command IDs, and event payloads for troubleshooting.',
          tone: AppPanelTone.neutral,
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text('Show Orchestrator diagnostics'),
            children: [
              OrchestratorPendingCommandsCard(),
              SizedBox(height: AppDimensions.spacingL),
              OrchestratorRecentEventsCard(),
              SizedBox(height: AppDimensions.spacingL),
              OrchestratorRuntimeSnapshotCard(),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  final String label;
  final bool complete;
  final bool unavailable;

  const _ChecklistRow({
    required this.label,
    required this.complete,
    this.unavailable = false,
  });

  @override
  Widget build(BuildContext context) {
    final icon = complete
        ? Icons.check_circle
        : unavailable
        ? Icons.radio_button_unchecked
        : Icons.pending;
    final color = complete
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXS),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}
