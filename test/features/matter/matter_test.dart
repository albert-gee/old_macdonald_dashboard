import 'dart:convert';

import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/matter/data/datasources/matter_cluster_asset_data_source.dart';
import 'package:dashboard/src/features/matter/data/repositories/matter_command_repository_impl.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_attribute_read_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_attribute_report.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_attribute_subscribe_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_cluster_command_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_controller_init_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_pair_ble_thread_request.dart';
import 'package:dashboard/src/features/matter/presentation/controllers/matter_event_controller.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_message.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('cluster asset data source parses XML clusters', () async {
    final result = await MatterClusterAssetDataSource().loadClusters();
    expect(result, isA<Success>());
    final clusters = (result as Success).value as List;
    expect(clusters, isNotEmpty);
  });

  test('command repository encodes all Matter commands', () async {
    final connection = RecordingConnectionRepository();
    final repository =
        MatterCommandRepositoryImpl(connectionRepository: connection);

    await repository.initializeController(
      const MatterControllerInitRequest(
        nodeId: '1',
        fabricId: 2,
        listenPort: 5540,
      ),
    );
    await repository.pairBleThread(
      const MatterPairBleThreadRequest(
        nodeId: '1',
        setupCode: '20202021',
        discriminator: '3840',
      ),
    );
    await repository.invokeClusterCommand(
      const MatterClusterCommandRequest(
        destinationId: '1',
        endpointId: 1,
        clusterId: 6,
        commandId: 1,
        commandData: '{}',
      ),
    );
    await repository.readAttribute(
      const MatterAttributeReadRequest(
        nodeId: '1',
        endpointId: 1,
        clusterId: 6,
        attributeId: 0,
      ),
    );
    await repository.subscribeAttribute(
      const MatterAttributeSubscribeRequest(
        nodeId: '1',
        endpointId: 1,
        clusterId: 6,
        attributeId: 0,
        minInterval: 1,
        maxInterval: 60,
      ),
    );

    final bodies = connection.sent
        .map((message) => jsonDecode(message) as Map<String, Object?>)
        .toList();

    expect(bodies.first, {
      'type': 'command',
      'action': 'matter.controller_init',
      'payload': {
        'node_id': '1',
        'fabric_id': 2,
        'listen_port': 5540,
      },
    });
    expect(bodies[1], {
      'type': 'command',
      'action': 'matter.pair_ble_thread',
      'payload': {
        'node_id': '1',
        'setup_code': '20202021',
        'discriminator': '3840',
      },
    });
    expect(bodies[2], {
      'type': 'command',
      'action': 'matter.cluster_command_invoke',
      'payload': {
        'destination_id': '1',
        'endpoint_id': 1,
        'cluster_id': 6,
        'command_id': 1,
        'command_data': '{}',
      },
    });
    expect(bodies[3], {
      'type': 'command',
      'action': 'matter.attribute_read',
      'payload': {
        'node_id': '1',
        'endpoint_id': 1,
        'cluster_id': 6,
        'attribute_id': 0,
      },
    });
    expect(bodies[4], {
      'type': 'command',
      'action': 'matter.attribute_subscribe',
      'payload': {
        'node_id': '1',
        'endpoint_id': 1,
        'cluster_id': 6,
        'attribute_id': 0,
        'min_interval': 1,
        'max_interval': 60,
      },
    });
  });

  test('matter event controller updates on events', () async {
    final controller = MatterEventController(
      messages: Stream<OrchestratorMessage>.fromIterable([
        const MatterCommissioningCompleteReceived(nodeId: 1, fabricIndex: 2),
        const MatterAttributeReportReceived(
          MatterAttributeReport(
            nodeId: 1,
            endpointId: 1,
            clusterId: 6,
            attributeId: 0,
            value: 'true',
          ),
        ),
        const MatterSubscribeDoneReceived(nodeId: 1, subscriptionId: 7),
      ]),
    );
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.recentEvents, hasLength(3));
  });
}
