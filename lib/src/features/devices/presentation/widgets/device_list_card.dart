import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/layout/app_responsive_grid.dart';
import 'package:dashboard/src/core/theme/app_colors.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/theme/app_text_styles.dart';
import 'package:dashboard/src/core/widgets/app_metric_tile.dart';
import 'package:dashboard/src/core/widgets/app_panel.dart';
import 'package:dashboard/src/features/devices/domain/entities/device_record.dart';
import 'device_rename_dialog.dart';

class DeviceListCard extends ConsumerWidget {
  const DeviceListCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deviceListControllerProvider);
    final controller = ref.read(deviceListControllerProvider.notifier);
    return AppPanel(
      title: 'Registered devices',
      subtitle:
          'Device rows show operational status first. Technical IDs are available in details.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: state.loading ? null : controller.refresh,
              icon: const Icon(Icons.refresh),
              label: Text(state.loading ? 'Refreshing...' : 'Refresh devices'),
            ),
          ),
          if (state.message != null) ...[
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              state.message!,
              style: const TextStyle(color: AppColors.warning),
            ),
          ],
          if (state.discoveryPending) ...[
            const SizedBox(height: AppDimensions.spacingM),
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: Text(
                    'Discovery pending for ${state.pendingDiscoveryDeviceIds.length} device(s). Registry data updates from state_snapshot and discovery events.',
                    style: AppTextStyles.mutedBody,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppDimensions.spacingL),
          if (state.devices.isEmpty && !state.loading)
            const Text(
              'No chamber devices are registered. Devices appear after commissioning and registration.',
            ),
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
    final state = ref.watch(deviceListControllerProvider);
    final controller = ref.read(deviceListControllerProvider.notifier);
    final discoveryPending = state.pendingDiscoveryDeviceIds.contains(
      device.deviceId,
    );
    final validCapabilities = device.capabilities
        .where((capability) => capability.isValid)
        .length;
    final invalidCapabilities = device.capabilities.length - validCapabilities;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingL),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          border: Border.all(
            color: invalidCapabilities > 0
                ? AppColors.warning.withValues(alpha: 0.45)
                : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    device.reachable ? Icons.sensors : Icons.sensors_off,
                    color: device.reachable
                        ? AppColors.success
                        : AppColors.neutral,
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(device.label, style: AppTextStyles.cardTitle),
                        const SizedBox(height: AppDimensions.spacingXS),
                        Text(
                          device.reachable ? 'Reachable' : 'Offline',
                          style: AppTextStyles.mutedBody,
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
                        tooltip: discoveryPending
                            ? 'Discovery pending'
                            : 'Refresh discovery',
                        icon: discoveryPending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.manage_search),
                        onPressed: discoveryPending
                            ? null
                            : () async {
                                await controller.refreshDevice(device.deviceId);
                              },
                      ),
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
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Remove device?'),
                              content: Text(
                                'Remove ${device.label} from the Dashboard device registry?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Remove'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await controller.remove(device.deviceId);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingL),
              AppResponsiveGrid(
                children: [
                  AppMetricTile(
                    label: 'Capabilities',
                    value: '${device.capabilities.length}',
                    tone: device.capabilities.isEmpty
                        ? AppMetricTone.warning
                        : AppMetricTone.good,
                  ),
                  AppMetricTile(
                    label: 'Usable',
                    value: '$validCapabilities',
                    tone: validCapabilities > 0
                        ? AppMetricTone.good
                        : AppMetricTone.warning,
                  ),
                  AppMetricTile(
                    label: 'Needs attention',
                    value: '$invalidCapabilities',
                    tone: invalidCapabilities > 0
                        ? AppMetricTone.warning
                        : AppMetricTone.neutral,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingM),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('Technical details'),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Device ID: ${device.deviceId}\nNode ID: ${device.nodeId}',
                    ),
                  ),
                ],
              ),
              if (device.capabilities.isEmpty)
                const Text(
                  'No device capabilities are registered. This device is not usable in Chamber workflows yet.',
                )
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
      'endpoint ${capability.endpointId ?? 'missing'}',
      'cluster ${capability.clusterId ?? 'missing'}',
      if (capability.attributeId != null) 'attribute ${capability.attributeId}',
      if (capability.commandId != null) 'command ${capability.commandId}',
    ].join(' | ');
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        capability.isValid ? Icons.extension : Icons.warning_amber,
        color: capability.isValid ? AppColors.success : AppColors.warning,
      ),
      title: Text('${capability.label} (${capability.semanticLabel})'),
      subtitle: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Text(
          capability.isValid
              ? 'Device capability ready.'
              : 'Capability needs registry details before use.',
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              capability.isValid
                  ? technical
                  : 'Missing details: ${capability.validationWarnings.join(' ')}\n$technical',
            ),
          ),
        ],
      ),
    );
  }
}
