import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/widgets/app_card.dart';

class ChamberSensorCards extends ConsumerStatefulWidget {
  const ChamberSensorCards({super.key});

  @override
  ConsumerState<ChamberSensorCards> createState() => _ChamberSensorCardsState();
}

class _ChamberSensorCardsState extends ConsumerState<ChamberSensorCards> {
  final _temperatureDevice = TextEditingController();
  final _pressureDevice = TextEditingController();

  @override
  void dispose() {
    _temperatureDevice.dispose();
    _pressureDevice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chamberControllerProvider);
    final controller = ref.read(chamberControllerProvider.notifier);
    return AppCard(
      title: 'Sensors',
      child: Column(
        children: [
          TextField(
            controller: _temperatureDevice,
            decoration: const InputDecoration(
              labelText: 'Temperature device ID',
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: state.loading
                  ? null
                  : () => controller.readTemperature(
                      _temperatureDevice.text.trim(),
                    ),
              icon: const Icon(Icons.thermostat),
              label: const Text('Read Temperature'),
            ),
          ),
          if (state.lastTemperatureCelsius != null)
            Text('${state.lastTemperatureCelsius} C'),
          const SizedBox(height: 16),
          TextField(
            controller: _pressureDevice,
            decoration: const InputDecoration(labelText: 'Pressure device ID'),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: state.loading
                  ? null
                  : () => controller.readPressure(_pressureDevice.text.trim()),
              icon: const Icon(Icons.speed),
              label: const Text('Read Pressure'),
            ),
          ),
          if (state.lastPressureKpa != null)
            Text('${state.lastPressureKpa} kPa'),
        ],
      ),
    );
  }
}
