import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_attribute_read_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_attribute_subscribe_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_cluster_command_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_controller_init_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_pair_ble_thread_request.dart';
import 'package:dashboard/src/features/matter/domain/repositories/matter_command_repository.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_command_result.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_command_client.dart';

final class MatterCommandRepositoryImpl implements MatterCommandRepository {
  final OrchestratorCommandClient _client;

  MatterCommandRepositoryImpl({required OrchestratorCommandClient client})
    : _client = client;

  @override
  Future<Result<OrchestratorCommandResult>> initializeController(
    MatterControllerInitRequest request,
  ) {
    return _send('matter.controller_init', {
      'node_id': request.nodeId,
      'fabric_id': request.fabricId,
      'listen_port': request.listenPort,
    });
  }

  @override
  Future<Result<OrchestratorCommandResult>> pairBleThread(
    MatterPairBleThreadRequest request,
  ) {
    return _send('matter.pair_ble_thread', {
      'node_id': request.nodeId,
      'setup_code': request.setupCode,
      'discriminator': request.discriminator,
    });
  }

  @override
  Future<Result<OrchestratorCommandResult>> invokeClusterCommand(
    MatterClusterCommandRequest request,
  ) {
    return _send('matter.cluster_command_invoke', {
      'destination_id': request.destinationId,
      'endpoint_id': request.endpointId,
      'cluster_id': request.clusterId,
      'command_id': request.commandId,
      'command_data': request.commandData,
    });
  }

  @override
  Future<Result<OrchestratorCommandResult>> readAttribute(
    MatterAttributeReadRequest request,
  ) {
    return _send('matter.attribute_read', {
      'node_id': request.nodeId,
      'endpoint_id': request.endpointId,
      'cluster_id': request.clusterId,
      'attribute_id': request.attributeId,
    });
  }

  @override
  Future<Result<OrchestratorCommandResult>> subscribeAttribute(
    MatterAttributeSubscribeRequest request,
  ) {
    return _send('matter.attribute_subscribe', {
      'node_id': request.nodeId,
      'endpoint_id': request.endpointId,
      'cluster_id': request.clusterId,
      'attribute_id': request.attributeId,
      'min_interval': request.minInterval,
      'max_interval': request.maxInterval,
    });
  }

  Future<Result<OrchestratorCommandResult>> _send(
    String action,
    Map<String, Object?> payload,
  ) {
    return _client.sendCommand(action, payload: payload);
  }
}
