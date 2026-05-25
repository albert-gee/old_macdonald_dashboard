import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/devices/data/repositories/device_repository_impl.dart';
import 'package:dashboard/src/features/devices/domain/entities/device_record.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_command_result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes.dart';

void main() {
  test('device.list parses devices', () async {
    final client = RecordingCommandClient()
      ..nextResult = const Success(
        OrchestratorCommandResult(
          requestId: 'req-1',
          action: 'device.list',
          ok: true,
          payload: {
            'devices': [
              {
                'device_id': 'bmp280-1',
                'node_id': '123',
                'label': 'BMP280 Sensor',
                'reachable': true,
                'capabilities': [
                  {
                    'capability_id': 'bmp280-1-temperature',
                    'semantic_type': 'temperature',
                    'endpoint_id': 1,
                    'cluster_id': 1026,
                    'attribute_id': 0,
                    'label': 'Temperature',
                  },
                ],
              },
            ],
          },
        ),
      );
    final repository = DeviceRepositoryImpl(client: client);

    final result = await repository.listDevices();
    expect(result, isA<Success>());
    final device = (result as Success).value.single;
    expect(device.label, 'BMP280 Sensor');
    expect(
      device.capabilities.single.semanticType,
      DeviceCapabilitySemanticType.temperature,
    );
    expect(client.commands.single.action, 'device.list');
  });

  test('device.rename does not require updated device payload', () async {
    final client = RecordingCommandClient()
      ..nextResult = const Success(
        OrchestratorCommandResult(
          requestId: 'req-1',
          action: 'device.rename',
          ok: true,
          payload: {'accepted': true},
        ),
      );
    final repository = DeviceRepositoryImpl(client: client);

    final result = await repository.renameDevice('relay-1', 'Mist Relay');

    expect(result, isA<Success<void>>());
    expect(client.commands.single.action, 'device.rename');
    expect(client.commands.single.payload, {
      'device_id': 'relay-1',
      'label': 'Mist Relay',
    });
  });
}
