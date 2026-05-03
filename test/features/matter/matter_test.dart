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
        nodeId: 1,
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

    expect(
      connection.sent
          .map((message) => jsonDecode(message) as Map<String, Object?>)
          .map((body) => body['action']),
      [
        'matter.controller_init',
        'matter.pair_ble_thread',
        'matter.cluster_command_invoke',
        'matter.attribute_read',
        'matter.attribute_subscribe',
      ],
    );
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
