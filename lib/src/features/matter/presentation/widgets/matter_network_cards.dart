import 'package:flutter/material.dart';

import 'package:dashboard/src/core/layout/app_responsive_grid.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_metric_tile.dart';
import 'package:dashboard/src/core/widgets/app_panel.dart';
import 'package:dashboard/src/features/devices/domain/entities/device_record.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_readiness.dart';
import 'package:dashboard/src/features/matter/presentation/controllers/matter_event_state.dart';
import 'package:dashboard/src/features/matter/presentation/widgets/matter_controller_init_form.dart';
import 'package:dashboard/src/features/matter/presentation/widgets/matter_pair_ble_thread_form.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_snapshot.dart';
import 'package:dashboard/src/features/orchestrator/presentation/controllers/orchestrator_runtime_state.dart';

class MatterReadinessCard extends StatelessWidget {
  final MatterReadiness readiness;
  final bool controllerInitialized;

  const MatterReadinessCard({
    super.key,
    required this.readiness,
    required this.controllerInitialized,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppPanel(
      title: 'Matter Device Network readiness',
      tone: readiness.canPair ? AppPanelTone.success : AppPanelTone.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Matter is used to commission and manage chamber sensors and actuators.',
          ),
          const SizedBox(height: AppDimensions.spacingL),
          AppResponsiveGrid(
            children: [
              AppMetricTile(
                label: 'Matter controller',
                value: controllerInitialized ? 'Ready' : 'Not initialized',
                tone: controllerInitialized
                    ? AppMetricTone.good
                    : AppMetricTone.warning,
              ),
              AppMetricTile(
                label: 'Pairing',
                value: readiness.canPair ? 'Available' : 'Not ready',
                tone: readiness.canPair
                    ? AppMetricTone.good
                    : AppMetricTone.warning,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Text(readiness.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppDimensions.spacingS),
          Text(readiness.meaning),
          if (readiness.threadReadinessInferred) ...[
            const SizedBox(height: AppDimensions.spacingS),
            const Text(
              'Thread readiness is inferred from Thread attachment and dataset presence. Border Router readiness is not separately reported yet.',
            ),
          ],
          const SizedBox(height: AppDimensions.spacingL),
          Text('Operational impact', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppDimensions.spacingS),
          Text(readiness.impact),
          const SizedBox(height: AppDimensions.spacingL),
          Text('Next action', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppDimensions.spacingS),
          Text(readiness.nextAction),
        ],
      ),
    );
  }
}

class MatterPairChamberDeviceCard extends StatelessWidget {
  final MatterReadiness readiness;

  const MatterPairChamberDeviceCard({super.key, required this.readiness});

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      title: 'Pair chamber device',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Use this when a chamber device is in commissioning mode and ready to join the Matter fabric.',
          ),
          if (readiness.state == MatterReadinessState.threadNotReady) ...[
            const SizedBox(height: AppDimensions.spacingM),
            const Text(
              'Complete Thread setup before pairing Matter-over-Thread devices.',
            ),
            const SizedBox(height: AppDimensions.spacingS),
            const Text('Go to Thread Network.'),
          ],
          if (readiness.state ==
              MatterReadinessState.controllerNotInitialized) ...[
            const SizedBox(height: AppDimensions.spacingM),
            const Text(
              'Initialize the Matter controller before pairing devices.',
            ),
            const SizedBox(height: AppDimensions.spacingM),
            const ExpansionTile(
              title: Text('Initialize Matter controller'),
              children: [MatterControllerInitForm()],
            ),
          ],
          const SizedBox(height: AppDimensions.spacingL),
          MatterPairBleThreadForm(
            enabled: readiness.canPair,
            submitLabel: 'Pair chamber device',
          ),
        ],
      ),
    );
  }
}

class MatterControllerSetupCard extends StatelessWidget {
  final bool controllerInitialized;

  const MatterControllerSetupCard({
    super.key,
    required this.controllerInitialized,
  });

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      title: 'Matter controller setup',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppMetricTile(
            label: 'Matter controller',
            value: controllerInitialized ? 'Ready' : 'Not initialized',
            tone: controllerInitialized
                ? AppMetricTone.good
                : AppMetricTone.warning,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          const Text(
            'Initialize the controller before commissioning chamber devices. Advanced controller fields are available below when setup is required.',
          ),
          const SizedBox(height: AppDimensions.spacingM),
          const ExpansionTile(
            title: Text('Controller setup'),
            children: [MatterControllerInitForm()],
          ),
        ],
      ),
    );
  }
}

class MatterCommissionedDevicesCard extends StatelessWidget {
  final List<CommissionedMatterNodeSnapshot> nodes;
  final List<DeviceRecord> registryDevices;

  const MatterCommissionedDevicesCard({
    super.key,
    required this.nodes,
    required this.registryDevices,
  });

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      title: 'Commissioned devices',
      child: nodes.isEmpty
          ? const Text('No commissioned Matter devices reported yet.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: nodes
                  .map((node) => _nodeSummary(context, node))
                  .toList(),
            ),
    );
  }

  Widget _nodeSummary(
    BuildContext context,
    CommissionedMatterNodeSnapshot node,
  ) {
    final device = _registryDeviceFor(node);
    final capabilityCount = device?.capabilities.length ?? 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            node.label?.trim().isNotEmpty == true
                ? node.label!
                : 'Commissioned device',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          Text('Node ID: ${node.nodeId}'),
          Text(
            device == null
                ? 'Commissioned node is not mapped to a Dashboard device record yet.'
                : 'Mapped to device registry.',
          ),
          if (device != null) Text('Capabilities: $capabilityCount'),
          if (node.reachable != null)
            Text(
              'Reachability: ${node.reachable! ? 'Reachable' : 'Not reachable'}',
            ),
        ],
      ),
    );
  }

  DeviceRecord? _registryDeviceFor(CommissionedMatterNodeSnapshot node) {
    for (final device in registryDevices) {
      if (device.nodeId == node.nodeId) return device;
    }
    return null;
  }
}

class MatterRegistryMappingCard extends StatelessWidget {
  final List<CommissionedMatterNodeSnapshot> nodes;
  final List<DeviceRecord> registryDevices;
  final bool registryLoading;
  final String? registryMessage;

  const MatterRegistryMappingCard({
    super.key,
    required this.nodes,
    required this.registryDevices,
    this.registryLoading = false,
    this.registryMessage,
  });

  @override
  Widget build(BuildContext context) {
    final mappedNodeIds = registryDevices
        .map((device) => device.nodeId)
        .toSet();
    final unmappedCount = nodes
        .where((node) => !mappedNodeIds.contains(node.nodeId))
        .length;
    final devicesWithCapabilities = registryDevices
        .where((device) => device.capabilities.isNotEmpty)
        .length;
    final devicesWithoutCapabilities =
        registryDevices.length - devicesWithCapabilities;
    return AppPanel(
      title: 'Registry mapping status',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppResponsiveGrid(
            children: [
              AppMetricTile(
                label: 'Commissioned nodes',
                value: '${nodes.length}',
                tone: nodes.isNotEmpty
                    ? AppMetricTone.good
                    : AppMetricTone.neutral,
              ),
              AppMetricTile(
                label: 'Registry devices',
                value: '${registryDevices.length}',
                tone: registryDevices.isNotEmpty
                    ? AppMetricTone.good
                    : AppMetricTone.neutral,
              ),
              AppMetricTile(
                label: 'Unmapped nodes',
                value: '$unmappedCount',
                tone: unmappedCount == 0 && nodes.isNotEmpty
                    ? AppMetricTone.good
                    : AppMetricTone.warning,
              ),
              AppMetricTile(
                label: 'With capabilities',
                value: '$devicesWithCapabilities',
                tone: devicesWithCapabilities > 0
                    ? AppMetricTone.good
                    : AppMetricTone.warning,
              ),
              AppMetricTile(
                label: 'Without capabilities',
                value: '$devicesWithoutCapabilities',
                tone: devicesWithoutCapabilities == 0
                    ? AppMetricTone.neutral
                    : AppMetricTone.warning,
              ),
            ],
          ),
          if (registryLoading) ...[
            const SizedBox(height: AppDimensions.spacingL),
            const Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: AppDimensions.spacingM),
                Text('Refreshing device registry...'),
              ],
            ),
          ],
          if (registryMessage != null) ...[
            const SizedBox(height: AppDimensions.spacingL),
            Text(registryMessage!),
          ],
          const SizedBox(height: AppDimensions.spacingL),
          const Text(
            'Pairing is not the final step. Add or verify device capabilities before using this device in Chamber controls.',
          ),
        ],
      ),
    );
  }
}

class MatterRecentActivityCard extends StatelessWidget {
  final List<MatterEvent> events;
  final List<OrchestratorEventLogEntry> runtimeEvents;

  const MatterRecentActivityCard({
    super.key,
    required this.events,
    required this.runtimeEvents,
  });

  @override
  Widget build(BuildContext context) {
    final runtimeMatterEvents = runtimeEvents
        .where((event) => event.type.startsWith('command_failed.matter.'))
        .map(_runtimeLabel)
        .toList();
    final labels = [
      ...runtimeMatterEvents,
      ...events.map(_eventLabel),
    ].take(8).toList();
    return AppPanel(
      title: 'Recent Matter activity',
      child: labels.isEmpty
          ? const Text('No Matter activity received yet.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: labels.map(Text.new).toList(),
            ),
    );
  }

  String _eventLabel(MatterEvent event) {
    return switch (event) {
      MatterCommissioningCompleteEvent() => 'Device commissioning completed',
      MatterAttributeReportEvent() => 'Attribute report received',
      MatterSubscribeDoneEvent() => 'Subscription established',
    };
  }

  String _runtimeLabel(OrchestratorEventLogEntry event) {
    return 'Matter command failed';
  }
}

class MatterAdvancedDiagnosticsCard extends StatelessWidget {
  const MatterAdvancedDiagnosticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPanel(
      title: 'Advanced diagnostics',
      tone: AppPanelTone.neutral,
      child: ExpansionTile(
        title: Text('For low-level Matter setup and troubleshooting.'),
        children: [
          Text(
            'Raw controller setup fields: controller node ID, Fabric ID, listen port.',
          ),
          SizedBox(height: AppDimensions.spacingM),
          Text('Raw pairing command: Pair BLE Thread.'),
          SizedBox(height: AppDimensions.spacingM),
          Text(
            'Cluster, endpoint, attribute, and raw command workflows remain available in Developer tools.',
          ),
        ],
      ),
    );
  }
}
