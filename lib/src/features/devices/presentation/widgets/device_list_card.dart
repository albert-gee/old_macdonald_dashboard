import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/widgets/app_card.dart';
import 'package:dashboard/src/features/devices/domain/entities/device_record.dart';
import 'device_rename_dialog.dart';

class DeviceListCard extends ConsumerWidget {
  const DeviceListCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deviceListControllerProvider);
    final controller = ref.read(deviceListControllerProvider.notifier);
    return AppCard(
      title: 'Device Registry',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FilledButton.icon(
                onPressed: state.loading ? null : controller.refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
              const SizedBox(width: 12),
              if (state.loading) const CircularProgressIndicator(),
            ],
          ),
          if (state.message != null) ...[
            const SizedBox(height: 12),
            Text(state.message!, style: TextStyle(color: Colors.red.shade700)),
          ],
          const SizedBox(height: 16),
          if (state.devices.isEmpty && !state.loading)
            const Text('No devices reported by the Orchestrator.'),
          for (final device in state.devices) _DeviceTile(device: device),
        ],
      ),
    );
  }
}

class _DeviceTile extends ConsumerWidget {
  final DeviceRecord device;

  const _DeviceTile({required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(deviceListControllerProvider.notifier);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    device.reachable ? Icons.sensors : Icons.sensors_off,
                    color: device.reachable ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${device.deviceId} | node ${device.nodeId} | '
                          '${device.reachable ? 'reachable' : 'offline'}',
                        ),
                        if (device.productName != null)
                          Text('Product: ${device.productName}'),
                        if (device.location != null)
                          Text('Location: ${device.location}'),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        tooltip: 'Rename',
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final label = await showDialog<String>(
                            context: context,
                            builder: (_) =>
                                DeviceRenameDialog(initialLabel: device.label),
                          );
                          if (label != null && label.isNotEmpty) {
                            await controller.rename(device.deviceId, label);
                          }
                        },
                      ),
                      IconButton(
                        tooltip: 'Remove',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => controller.remove(device.deviceId),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (device.capabilities.isEmpty)
                const Text('No capabilities registered.')
              else
                Column(
                  children: [
                    for (final capability in device.capabilities)
                      _CapabilityRow(capability: capability),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CapabilityRow extends StatelessWidget {
  final DeviceCapability capability;

  const _CapabilityRow({required this.capability});

  @override
  Widget build(BuildContext context) {
    final technical = [
      'endpoint ${capability.endpointId}',
      'cluster ${capability.clusterId}',
      if (capability.attributeId != null) 'attribute ${capability.attributeId}',
      if (capability.commandId != null) 'command ${capability.commandId}',
    ].join(' | ');
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.extension),
      title: Text('${capability.label} (${capability.semanticLabel})'),
      subtitle: Text(technical),
    );
  }
}
