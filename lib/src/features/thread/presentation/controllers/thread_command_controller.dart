import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_command_result.dart';
import 'package:dashboard/src/features/thread/domain/repositories/thread_command_repository.dart';
import 'thread_command_state.dart';

typedef ThreadCommandOperation =
    Future<Result<OrchestratorCommandResult>> Function();

final class ThreadCommandController extends StateNotifier<ThreadCommandState> {
  final ThreadCommandRepository _repository;

  ThreadCommandController({required ThreadCommandRepository repository})
    : _repository = repository,
      super(const ThreadCommandState());

  Future<void> enable() => _run(_repository.enable, 'Thread enabled.');
  Future<void> disable() => _run(_repository.disable, 'Thread disabled.');
  Future<void> refreshStatus() =>
      _run(_repository.refreshStatus, 'Thread status refreshed.');
  Future<void> refreshAttachment() =>
      _run(_repository.refreshAttachment, 'Thread attachment refreshed.');
  Future<void> refreshRole() =>
      _run(_repository.refreshRole, 'Thread role refreshed.');
  Future<void> refreshActiveDataset() => _run(
    _repository.refreshActiveDataset,
    'Thread active dataset refreshed.',
  );
  Future<void> refreshThreadState() async {
    state = const ThreadCommandState(submitting: true);
    final results = [
      await _repository.refreshStatus(),
      await _repository.refreshAttachment(),
      await _repository.refreshRole(),
      await _repository.refreshActiveDataset(),
    ];
    FailureResult? failure;
    for (final result in results) {
      if (result case FailureResult()) {
        failure = result;
        break;
      }
    }
    state = failure == null
        ? const ThreadCommandState(
            message: 'Thread state refresh requested.',
            success: true,
          )
        : ThreadCommandState(message: failure.failure.message);
  }

  Future<void> refreshUnicastAddresses() => _run(
    _repository.refreshUnicastAddresses,
    'Thread unicast addresses refreshed.',
  );
  Future<void> refreshMulticastAddresses() => _run(
    _repository.refreshMulticastAddresses,
    'Thread multicast addresses refreshed.',
  );
  Future<void> initBorderRouter() =>
      _run(_repository.initBorderRouter, 'Thread border router initialized.');
  Future<void> deinitBorderRouter() => _run(
    _repository.deinitBorderRouter,
    'Thread border router deinitialized.',
  );

  Future<void> _run(
    ThreadCommandOperation operation,
    String successMessage,
  ) async {
    state = const ThreadCommandState(submitting: true);
    final result = await operation();
    state = switch (result) {
      Success() => ThreadCommandState(message: successMessage, success: true),
      FailureResult(failure: final failure) => ThreadCommandState(
        message: failure.message,
      ),
    };
  }
}
