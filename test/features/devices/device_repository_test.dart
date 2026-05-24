import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/devices/data/repositories/device_repository_impl.dart';
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
                'device_id': 'temp-1',
                'node_id': '123',
                'endpoint_id': 1,
                'device_type_id': '0x0302',
                'label': 'Temperature',
                'reachable': true,
              },
            ],
          },
        ),
      );
    final repository = DeviceRepositoryImpl(client: client);

    final result = await repository.listDevices();
    expect(result, isA<Success>());
    expect((result as Success).value.single.label, 'Temperature');
    expect(client.commands.single.action, 'device.list');
  });
}
