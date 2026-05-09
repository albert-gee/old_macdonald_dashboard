import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_attribute_read_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_attribute_subscribe_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_cluster_command_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_controller_init_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_pair_ble_thread_request.dart';
import 'package:dashboard/src/features/matter/domain/repositories/matter_command_repository.dart';
import 'package:dashboard/src/features/orchestrator/data/dtos/outbound_orchestrator_command_dto.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_connection_repository.dart';

final class MatterCommandRepositoryImpl implements MatterCommandRepository {
  final OrchestratorConnectionRepository _connectionRepository;

  MatterCommandRepositoryImpl({
    required OrchestratorConnectionRepository connectionRepository,
  }) : _connectionRepository = connectionRepository;

  @override
  Future<Result<void>> initializeController(
      MatterControllerInitRequest request) {
    return _send('matter.controller_init', {
      'node_id': request.nodeId,
      'fabric_id': request.fabricId,
      'listen_port': request.listenPort,
    });
  }

  @override
  Future<Result<void>> pairBleThread(MatterPairBleThreadRequest request) {
    return _send('matter.pair_ble_thread', {
      'node_id': request.nodeId,
      'setup_code': request.setupCode,
      'discriminator': request.discriminator,
    });
  }

  @override
  Future<Result<void>> invokeClusterCommand(
      MatterClusterCommandRequest request) {
    return _send('matter.cluster_command_invoke', {
      'destination_id': request.destinationId,
      'endpoint_id': request.endpointId,
      'cluster_id': request.clusterId,
      'command_id': request.commandId,
      'command_data': request.commandData,
    });
  }

  @override
  Future<Result<void>> readAttribute(MatterAttributeReadRequest request) {
    return _send('matter.attribute_read', {
      'node_id': request.nodeId,
      'endpoint_id': request.endpointId,
      'cluster_id': request.clusterId,
      'attribute_id': request.attributeId,
    });
  }

  @override
  Future<Result<void>> subscribeAttribute(
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

  Future<Result<void>> _send(String action, Map<String, Object?> payload) {
    return _connectionRepository.sendRaw(
      OutboundOrchestratorCommandDto(
        action: action,
        payload: payload,
      ).toJsonString(),
    );
  }
}
