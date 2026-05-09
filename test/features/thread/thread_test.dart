import 'dart:convert';

import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_message.dart';
import 'package:dashboard/src/features/thread/data/repositories/thread_command_repository_impl.dart';
import 'package:dashboard/src/features/thread/domain/entities/thread_dataset_init_request.dart';
import 'package:dashboard/src/features/thread/presentation/controllers/thread_status_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes.dart';

void main() {
  test('command repository encodes every Thread action', () async {
    final connection = RecordingConnectionRepository();
    final repository =
        ThreadCommandRepositoryImpl(connectionRepository: connection);

    await repository.enable();
    await repository.disable();
    await repository.refreshStatus();
    await repository.refreshAttachment();
    await repository.refreshRole();
    await repository.refreshActiveDataset();
    await repository.refreshUnicastAddresses();
    await repository.refreshMulticastAddresses();
    await repository.initBorderRouter();
    await repository.deinitBorderRouter();

    final bodies = connection.sent
        .map((message) => jsonDecode(message) as Map<String, Object?>)
        .toList();

    expect(bodies, [
      {
        'type': 'command',
        'action': 'thread.enable',
        'payload': <String, Object?>{},
      },
      {
        'type': 'command',
        'action': 'thread.disable',
        'payload': <String, Object?>{},
      },
      {
        'type': 'command',
        'action': 'thread.status_get',
        'payload': <String, Object?>{},
      },
      {
        'type': 'command',
        'action': 'thread.attached_get',
        'payload': <String, Object?>{},
      },
      {
        'type': 'command',
        'action': 'thread.role_get',
        'payload': <String, Object?>{},
      },
      {
        'type': 'command',
        'action': 'thread.active_dataset_get',
        'payload': <String, Object?>{},
      },
      {
        'type': 'command',
        'action': 'thread.unicast_addresses_get',
        'payload': <String, Object?>{},
      },
      {
        'type': 'command',
        'action': 'thread.multicast_addresses_get',
        'payload': <String, Object?>{},
      },
      {
        'type': 'command',
        'action': 'thread.br_init',
        'payload': <String, Object?>{},
      },
      {
        'type': 'command',
        'action': 'thread.br_deinit',
        'payload': <String, Object?>{},
      },
    ]);
  });

  test('dataset init encodes master_key', () async {
    final connection = RecordingConnectionRepository();
    final repository =
        ThreadCommandRepositoryImpl(connectionRepository: connection);

    await repository.initDataset(
      const ThreadDatasetInitRequest(
        channel: 15,
        panId: 1,
        networkName: 'mesh',
        extendedPanId: 'epan',
        meshLocalPrefix: 'fd00::/64',
        networkKey: 'key',
        pskc: 'pskc',
      ),
    );

    final body = jsonDecode(connection.sent.single) as Map<String, Object?>;
    final payload = body['payload'] as Map<String, Object?>;
    expect(body['type'], 'command');
    expect(body['action'], 'thread.dataset.init');
    expect(payload, {
      'channel': 15,
      'pan_id': 1,
      'network_name': 'mesh',
      'extended_pan_id': 'epan',
      'mesh_local_prefix': 'fd00::/64',
      'master_key': 'key',
      'pskc': 'pskc',
    });
    expect(payload['master_key'], 'key');
    expect(payload.containsKey('network_key'), isFalse);
  });

  test('status controller updates from orchestrator messages', () async {
    final stream = Stream<OrchestratorMessage>.fromIterable([
      const ThreadStackStatusReceived(true),
      const ThreadRoleReceived('leader'),
    ]);
    final controller = ThreadStatusController(messages: stream);
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.status.stackRunning, isTrue);
    expect(controller.state.status.role, 'leader');
  });
}
