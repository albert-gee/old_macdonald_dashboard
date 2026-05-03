import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_attribute_read_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_attribute_subscribe_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_cluster_command_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_controller_init_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_pair_ble_thread_request.dart';
import 'package:dashboard/src/features/matter/domain/repositories/matter_command_repository.dart';
import 'matter_command_state.dart';

typedef MatterCommandOperation = Future<Result<void>> Function();

final class MatterCommandController extends StateNotifier<MatterCommandState> {
  final MatterCommandRepository _repository;

  MatterCommandController({required MatterCommandRepository repository})
      : _repository = repository,
        super(const MatterCommandState());

  Future<void> initializeController(MatterControllerInitRequest request) =>
      _run(
        () => _repository.initializeController(request),
        'Matter controller init command sent.',
      );

  Future<void> pairBleThread(MatterPairBleThreadRequest request) => _run(
        () => _repository.pairBleThread(request),
        'Matter BLE Thread pairing command sent.',
      );

  Future<void> invokeClusterCommand(MatterClusterCommandRequest request) =>
      _run(
        () => _repository.invokeClusterCommand(request),
        'Matter cluster command sent.',
      );

  Future<void> readAttribute(MatterAttributeReadRequest request) => _run(
        () => _repository.readAttribute(request),
        'Matter attribute read command sent.',
      );

  Future<void> subscribeAttribute(MatterAttributeSubscribeRequest request) =>
      _run(
        () => _repository.subscribeAttribute(request),
        'Matter attribute subscribe command sent.',
      );

  Future<void> _run(
      MatterCommandOperation operation, String successMessage) async {
    state = const MatterCommandState(submitting: true);
    final result = await operation();
    state = switch (result) {
      Success() => MatterCommandState(message: successMessage, success: true),
      FailureResult(failure: final failure) =>
        MatterCommandState(message: failure.message),
    };
  }
}
