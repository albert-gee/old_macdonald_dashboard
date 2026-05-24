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
    ).readTemperature('temp-1');
    expect((result as Success).value, 23.4);
    expect(client.commands.single.action, 'device.temperature.read');
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
      (await repository.readPressure('pressure-1') as Success).value,
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
    await repository.setRelay('relay-1', true);
    expect(client.commands.map((command) => command.action), [
      'device.pressure.read',
      'device.relay.set',
    ]);
  });
}
