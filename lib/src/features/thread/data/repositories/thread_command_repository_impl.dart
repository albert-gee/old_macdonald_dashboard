import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_command_result.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_command_client.dart';
import 'package:dashboard/src/features/thread/domain/entities/thread_dataset_init_request.dart';
import 'package:dashboard/src/features/thread/domain/repositories/thread_command_repository.dart';

final class ThreadCommandRepositoryImpl implements ThreadCommandRepository {
  final OrchestratorCommandClient _client;

  ThreadCommandRepositoryImpl({required OrchestratorCommandClient client})
    : _client = client;

  @override
  Future<Result<OrchestratorCommandResult>> enable() => _send('thread.enable');

  @override
  Future<Result<OrchestratorCommandResult>> disable() =>
      _send('thread.disable');

  @override
  Future<Result<OrchestratorCommandResult>> refreshStatus() =>
      _send('thread.status_get');

  @override
  Future<Result<OrchestratorCommandResult>> refreshAttachment() =>
      _send('thread.attached_get');

  @override
  Future<Result<OrchestratorCommandResult>> refreshRole() =>
      _send('thread.role_get');

  @override
  Future<Result<OrchestratorCommandResult>> refreshActiveDataset() =>
      _send('thread.active_dataset_get');

  @override
  Future<Result<OrchestratorCommandResult>> refreshUnicastAddresses() =>
      _send('thread.unicast_addresses_get');

  @override
  Future<Result<OrchestratorCommandResult>> refreshMulticastAddresses() =>
      _send('thread.multicast_addresses_get');

  @override
  Future<Result<OrchestratorCommandResult>> initBorderRouter() =>
      _send('thread.br_init');

  @override
  Future<Result<OrchestratorCommandResult>> deinitBorderRouter() =>
      _send('thread.br_deinit');

  @override
  Future<Result<OrchestratorCommandResult>> initDataset(
    ThreadDatasetInitRequest request,
  ) {
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

  Future<Result<OrchestratorCommandResult>> _send(
    String action, {
    Map<String, Object?> payload = const <String, Object?>{},
  }) {
    return _client.sendCommand(action, payload: payload);
  }
}
