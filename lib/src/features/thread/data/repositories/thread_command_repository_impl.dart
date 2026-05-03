import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/orchestrator/data/dtos/outbound_orchestrator_command_dto.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_connection_repository.dart';
import 'package:dashboard/src/features/thread/domain/entities/thread_dataset_init_request.dart';
import 'package:dashboard/src/features/thread/domain/repositories/thread_command_repository.dart';

final class ThreadCommandRepositoryImpl implements ThreadCommandRepository {
  final OrchestratorConnectionRepository _connectionRepository;

  ThreadCommandRepositoryImpl({
    required OrchestratorConnectionRepository connectionRepository,
  }) : _connectionRepository = connectionRepository;

  @override
  Future<Result<void>> enable() => _send('thread.enable');

  @override
  Future<Result<void>> disable() => _send('thread.disable');

  @override
  Future<Result<void>> refreshStatus() => _send('thread.status_get');

  @override
  Future<Result<void>> refreshAttachment() => _send('thread.attached_get');

  @override
  Future<Result<void>> refreshRole() => _send('thread.role_get');

  @override
  Future<Result<void>> refreshActiveDataset() =>
      _send('thread.active_dataset_get');

  @override
  Future<Result<void>> refreshUnicastAddresses() =>
      _send('thread.unicast_addresses_get');

  @override
  Future<Result<void>> refreshMulticastAddresses() =>
      _send('thread.multicast_addresses_get');

  @override
  Future<Result<void>> initBorderRouter() => _send('thread.br_init');

  @override
  Future<Result<void>> deinitBorderRouter() => _send('thread.br_deinit');

  @override
  Future<Result<void>> initDataset(ThreadDatasetInitRequest request) {
    return _send(
      'thread.dataset.init',
      payload: {
        'channel': request.channel,
        'pan_id': request.panId,
        'network_name': request.networkName,
        'extended_pan_id': request.extendedPanId,
        'mesh_local_prefix': request.meshLocalPrefix,
        'master_key': request.networkKey,
        'pskc': request.pskc,
      },
    );
  }

  Future<Result<void>> _send(
    String action, {
    Map<String, Object?>? payload,
  }) {
    return _connectionRepository.sendRaw(
      OutboundOrchestratorCommandDto(
        action: action,
        payload: payload,
      ).toJsonString(),
    );
  }
}
