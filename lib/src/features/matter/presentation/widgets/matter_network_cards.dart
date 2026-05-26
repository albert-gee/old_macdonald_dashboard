import 'package:flutter/material.dart';

import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_card.dart';
import 'package:dashboard/src/core/widgets/app_status_card.dart';
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
    return AppCard(
      title: 'Matter Device Network readiness',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Matter is used to commission and manage chamber sensors and actuators.',
          ),
          const SizedBox(height: AppDimensions.spacingL),
          Wrap(
            spacing: AppDimensions.spacingM,
            runSpacing: AppDimensions.spacingM,
            children: [
              AppStatusCard(
                title: 'Matter controller',
                value: controllerInitialized ? 'Ready' : 'Not initialized',
                active: controllerInitialized,
              ),
              AppStatusCard(
                title: 'Pairing',
                value: readiness.canPair ? 'Available' : 'Not ready',
                active: readiness.canPair,
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
    return AppCard(
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
    return AppCard(
      title: 'Matter controller setup',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppStatusCard(
            title: 'Matter controller',
            value: controllerInitialized ? 'Ready' : 'Not initialized',
            active: controllerInitialized,
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
    return AppCard(
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

  const MatterRegistryMappingCard({
    super.key,
    required this.nodes,
    required this.registryDevices,
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
    return AppCard(
      title: 'Registry mapping status',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppDimensions.spacingM,
            runSpacing: AppDimensions.spacingM,
            children: [
              AppStatusCard(
                title: 'Commissioned nodes',
                value: '${nodes.length}',
                active: nodes.isNotEmpty,
              ),
              AppStatusCard(
                title: 'Registry devices',
                value: '${registryDevices.length}',
                active: registryDevices.isNotEmpty,
              ),
              AppStatusCard(
                title: 'Unmapped nodes',
                value: '$unmappedCount',
                active: unmappedCount == 0 && nodes.isNotEmpty,
              ),
              AppStatusCard(
                title: 'With capabilities',
                value: '$devicesWithCapabilities',
                active: devicesWithCapabilities > 0,
              ),
              AppStatusCard(
                title: 'Without capabilities',
                value: '$devicesWithoutCapabilities',
                active: devicesWithoutCapabilities == 0,
              ),
            ],
          ),
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
    return AppCard(
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
    return const AppCard(
      title: 'Advanced diagnostics',
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
