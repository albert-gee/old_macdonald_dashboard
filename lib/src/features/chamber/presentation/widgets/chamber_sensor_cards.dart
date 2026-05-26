import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/layout/app_responsive_grid.dart';
import 'package:dashboard/src/core/theme/app_colors.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/theme/app_text_styles.dart';
import 'package:dashboard/src/core/widgets/app_metric_tile.dart';
import 'package:dashboard/src/core/widgets/app_panel.dart';
import 'package:dashboard/src/features/chamber/presentation/controllers/chamber_state.dart';

class ChamberSensorCards extends ConsumerWidget {
  const ChamberSensorCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chamberControllerProvider);
    final controller = ref.read(chamberControllerProvider.notifier);
    return AppPanel(
      title: 'Environmental readings',
      subtitle:
          'Read environmental values from registered chamber sensor capabilities.',
      tone: state.temperatureOptions.isEmpty && state.pressureOptions.isEmpty
          ? AppPanelTone.warning
          : AppPanelTone.info,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: state.loadingDevices ? null : controller.loadDevices,
              icon: const Icon(Icons.refresh),
              label: Text(
                state.loadingDevices
                    ? 'Refreshing devices...'
                    : 'Refresh devices',
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          AppResponsiveGrid(
            minTileWidth: 280,
            children: [
              _SensorReadTile(
                title: 'Temperature',
                icon: Icons.thermostat,
                unit: 'C',
                options: state.temperatureOptions,
                selected: state.selectedTemperature,
                reading: state.temperature,
                emptyText:
                    'No environmental temperature capability is registered.',
                onChanged: controller.selectTemperature,
                onRead: state.temperature.commandPending
                    ? null
                    : controller.readTemperature,
              ),
              _SensorReadTile(
                title: 'Pressure',
                icon: Icons.speed,
                unit: 'kPa',
                options: state.pressureOptions,
                selected: state.selectedPressure,
                reading: state.pressure,
                emptyText: 'No pressure capability is registered.',
                onChanged: controller.selectPressure,
                onRead: state.pressure.commandPending
                    ? null
                    : controller.readPressure,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SensorReadTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String unit;
  final List<DeviceSelection> options;
  final DeviceSelection? selected;
  final SensorReadingState<double> reading;
  final String emptyText;
  final ValueChanged<DeviceSelection?> onChanged;
  final VoidCallback? onRead;

  const _SensorReadTile({
    required this.title,
    required this.icon,
    required this.unit,
    required this.options,
    required this.selected,
    required this.reading,
    required this.emptyText,
    required this.onChanged,
    required this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    final selectedValue = options.contains(selected) ? selected : null;
    final tile = AppMetricTile(
      label: '$title reading',
      value: _readingValue(),
      detail: _readingDetail(selectedValue),
      icon: icon,
      tone: _tone(selectedValue),
    );
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tile,
          const SizedBox(height: AppDimensions.spacingL),
          if (options.isEmpty)
            Text(emptyText, style: AppTextStyles.mutedBody)
          else
            DropdownButtonFormField<DeviceSelection>(
              isExpanded: true,
              initialValue: selectedValue,
              decoration: InputDecoration(
                labelText: '$title device function',
                prefixIcon: Icon(icon),
              ),
              items: [
                for (final option in options)
                  DropdownMenuItem(
                    value: option,
                    child: Text(
                      '${option.label}${option.reachable ? '' : ' (offline)'}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: onChanged,
            ),
          const SizedBox(height: AppDimensions.spacingM),
          Wrap(
            spacing: AppDimensions.spacingS,
            runSpacing: AppDimensions.spacingS,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: selectedValue == null ? null : onRead,
                icon: Icon(icon),
                label: Text('Read $title'),
              ),
              if (reading.commandPending)
                const Text('Command accepted')
              else if (reading.waitingForReport)
                const Text('Waiting for report'),
            ],
          ),
          if (reading.error != null) ...[
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              reading.error!,
              style: const TextStyle(color: AppColors.warning),
            ),
          ],
        ],
      ),
    );
  }

  String _readingValue() {
    if (reading.commandPending) return 'Pending';
    if (reading.waitingForReport) return 'Waiting';
    if (reading.value == null) return 'No reading';
    return '${reading.value} $unit';
  }

  String _readingDetail(DeviceSelection? selectedValue) {
    if (selectedValue == null) {
      return 'Select a device function before reading.';
    }
    if (!selectedValue.reachable) return 'Selected device is reported offline.';
    if (reading.updatedAt != null) return 'Updated ${reading.updatedAt}';
    return 'Selected function: ${selectedValue.label}';
  }

  AppMetricTone _tone(DeviceSelection? selectedValue) {
    if (selectedValue == null) return AppMetricTone.neutral;
    if (reading.error != null) return AppMetricTone.warning;
    if (reading.commandPending || reading.waitingForReport) {
      return AppMetricTone.pending;
    }
    if (reading.value != null) return AppMetricTone.good;
    return AppMetricTone.info;
  }
}
