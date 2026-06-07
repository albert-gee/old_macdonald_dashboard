import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/chamber/data/repositories/chamber_repository_impl.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_command_result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes.dart';

void main() {
  test('temperature command parses payload', () async {
    final client = RecordingCommandClient()
      ..nextResult = const Success(
        OrchestratorCommandResult(
          requestId: 'req-1',
          action: 'device.temperature.read',
          ok: true,
          payload: {'temperature_celsius': 23.4},
        ),
      );
    final result = await ChamberRepositoryImpl(
      client: client,
    ).readTemperature('temp-1', 'temp-cap-1');
    expect((result as Success).value.value, 23.4);
    expect(client.commands.single.action, 'device.temperature.read');
    expect(client.commands.single.payload, {
      'device_id': 'temp-1',
      'capability_id': 'temp-cap-1',
    });
  });

  test('temperature command accepts async report delivery', () async {
    final client = RecordingCommandClient()
      ..nextResult = const Success(
        OrchestratorCommandResult(
          requestId: 'req-1',
          action: 'device.temperature.read',
          ok: true,
          payload: {
            'device_id': 'sensor-1',
            'accepted': true,
            'result_delivery': 'matter.attribute_report',
          },
        ),
      );
    final result = await ChamberRepositoryImpl(
      client: client,
    ).readTemperature('sensor-1', 'sensor-temp');
    final read = (result as Success).value;
    expect(read.value, isNull);
    expect(read.waitingForReport, true);
  });

  test('pressure and relay commands use semantic actions', () async {
    final client = RecordingCommandClient()
      ..nextResult = const Success(
        OrchestratorCommandResult(
          requestId: 'req-1',
          action: 'device.pressure.read',
          ok: true,
          payload: {'pressure_kpa': 101.3},
        ),
      );
    final repository = ChamberRepositoryImpl(client: client);
    expect(
      (await repository.readPressure('pressure-1', 'pressure-cap') as Success)
          .value
          .value,
      101.3,
    );
    client.nextResult = const Success(
      OrchestratorCommandResult(
        requestId: 'req-2',
        action: 'device.relay.set',
        ok: true,
        payload: {'on': true},
      ),
    );
    await repository.setRelay('actuator-1', 'actuator-1-onoff', true);
    expect(client.commands.map((command) => command.action), [
      'device.pressure.read',
      'device.relay.set',
    ]);
    expect(client.commands.first.payload, {
      'device_id': 'pressure-1',
      'capability_id': 'pressure-cap',
    });
    expect(client.commands.last.payload, {
      'device_id': 'actuator-1',
      'capability_id': 'actuator-1-onoff',
      'on': true,
    });
  });

  test('temperature control rule upsert sends capability references', () async {
    final client = RecordingCommandClient()
      ..nextResult = const Success(
        OrchestratorCommandResult(
          requestId: 'req-1',
          action: 'control.temperature.upsert',
          ok: true,
          payload: {
            'configured': true,
            'enabled': true,
            'min_celsius': 21.5,
            'max_celsius': 26.5,
            'state': 'idle',
          },
        ),
      );
    final repository = ChamberRepositoryImpl(client: client);

    await repository.saveTemperatureRule(
      sensorDeviceId: 'sensor-1',
      sensorCapabilityId: 'temperature-cap',
      actuatorDeviceId: 'actuator-1',
      actuatorCapabilityId: 'relay-cap',
      minCelsius: 21.5,
      maxCelsius: 26.5,
      enabled: true,
    );

    expect(client.commands.single.action, 'control.temperature.upsert');
    expect(client.commands.single.payload, {
      'rule_id': 'main-air-temperature-fan',
      'chamber_id': 'main',
      'enabled': true,
      'mode': 'cooling',
      'sensor': {'device_id': 'sensor-1', 'capability_id': 'temperature-cap'},
      'actuator': {'device_id': 'actuator-1', 'capability_id': 'relay-cap'},
      'min_celsius': 21.5,
      'max_celsius': 26.5,
    });
  });
}
