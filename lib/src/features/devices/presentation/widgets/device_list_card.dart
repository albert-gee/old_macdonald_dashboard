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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        device.reachable ? Icons.sensors : Icons.sensors_off,
        color: device.reachable ? Colors.green : Colors.grey,
      ),
      title: Text(device.label),
      subtitle: Text(
        '${device.deviceId} | node ${device.nodeId} | endpoint '
        '${device.endpointId} | ${device.deviceTypeId}',
      ),
      trailing: Wrap(
        spacing: 4,
        children: [
          IconButton(
            tooltip: 'Rename',
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final label = await showDialog<String>(
                context: context,
                builder: (_) => DeviceRenameDialog(initialLabel: device.label),
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
    );
  }
}
