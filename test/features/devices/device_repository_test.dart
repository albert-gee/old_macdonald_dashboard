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
                'device_id': 'sensor-1',
                'node_id': '123',
                'label': 'Environmental sensor',
                'reachable': true,
                'capabilities': [
                  {
                    'capability_id': 'capability-1',
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
    expect(device.label, 'Environmental sensor');
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

    final result = await repository.renameDevice(
      'actuator-1',
      'Switchable actuator',
    );

    expect(result, isA<Success<void>>());
    expect(client.commands.single.action, 'device.rename');
    expect(client.commands.single.payload, {
      'device_id': 'actuator-1',
      'label': 'Switchable actuator',
    });
  });
}
