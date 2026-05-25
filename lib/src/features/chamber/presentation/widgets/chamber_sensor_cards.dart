import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/widgets/app_card.dart';
import 'package:dashboard/src/features/chamber/presentation/controllers/chamber_state.dart';

class ChamberSensorCards extends ConsumerWidget {
  const ChamberSensorCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chamberControllerProvider);
    final controller = ref.read(chamberControllerProvider.notifier);
    return AppCard(
      title: 'Sensors',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FilledButton.icon(
                onPressed: state.loadingDevices ? null : controller.loadDevices,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Devices'),
              ),
              if (state.loadingDevices) ...[
                const SizedBox(width: 12),
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _SensorReadSection(
            title: 'Temperature',
            icon: Icons.thermostat,
            unit: 'C',
            options: state.temperatureOptions,
            selected: state.selectedTemperature,
            reading: state.temperature,
            emptyText: 'No temperature capabilities registered.',
            onChanged: controller.selectTemperature,
            onRead: state.temperature.commandPending
                ? null
                : controller.readTemperature,
          ),
          const SizedBox(height: 20),
          _SensorReadSection(
            title: 'Pressure',
            icon: Icons.speed,
            unit: 'kPa',
            options: state.pressureOptions,
            selected: state.selectedPressure,
            reading: state.pressure,
            emptyText: 'No pressure capabilities registered.',
            onChanged: controller.selectPressure,
            onRead: state.pressure.commandPending
                ? null
                : controller.readPressure,
          ),
        ],
      ),
    );
  }
}

class _SensorReadSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String unit;
  final List<DeviceSelection> options;
  final DeviceSelection? selected;
  final SensorReadingState<double> reading;
  final String emptyText;
  final ValueChanged<DeviceSelection?> onChanged;
  final VoidCallback? onRead;

  const _SensorReadSection({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (options.isEmpty)
          Text(emptyText)
        else
          DropdownButtonFormField<DeviceSelection>(
            initialValue: selectedValue,
            decoration: InputDecoration(
              labelText: '$title capability',
              prefixIcon: Icon(icon),
            ),
            items: [
              for (final option in options)
                DropdownMenuItem(
                  value: option,
                  child: Text(
                    '${option.label}${option.reachable ? '' : ' (offline)'}',
                  ),
                ),
            ],
            onChanged: onChanged,
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: selectedValue == null ? null : onRead,
              icon: Icon(icon),
              label: Text('Read $title'),
            ),
            if (reading.commandPending)
              const Text('Command pending')
            else if (reading.waitingForReport)
              const Text('Waiting for report')
            else if (reading.value != null)
              Text('${reading.value} $unit')
            else
              const Text('No reading yet'),
          ],
        ),
        if (reading.rawMeasuredValue != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('Raw measured value: ${reading.rawMeasuredValue}'),
          ),
        if (reading.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              reading.error!,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
      ],
    );
  }
}
