import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/thread/domain/repositories/thread_command_repository.dart';
import 'thread_command_state.dart';

typedef ThreadCommandOperation = Future<Result<void>> Function();

final class ThreadCommandController extends StateNotifier<ThreadCommandState> {
  final ThreadCommandRepository _repository;

  ThreadCommandController({required ThreadCommandRepository repository})
      : _repository = repository,
        super(const ThreadCommandState());

  Future<void> enable() =>
      _run(_repository.enable, 'Thread enable command sent.');
  Future<void> disable() =>
      _run(_repository.disable, 'Thread disable command sent.');
  Future<void> refreshStatus() =>
      _run(_repository.refreshStatus, 'Thread status refresh command sent.');
  Future<void> refreshAttachment() => _run(
        _repository.refreshAttachment,
        'Thread attachment refresh command sent.',
      );
  Future<void> refreshRole() =>
      _run(_repository.refreshRole, 'Thread role refresh command sent.');
  Future<void> refreshActiveDataset() => _run(
        _repository.refreshActiveDataset,
        'Thread active dataset refresh command sent.',
      );
  Future<void> refreshUnicastAddresses() => _run(
        _repository.refreshUnicastAddresses,
        'Thread unicast address refresh command sent.',
      );
  Future<void> refreshMulticastAddresses() => _run(
        _repository.refreshMulticastAddresses,
        'Thread multicast address refresh command sent.',
      );
  Future<void> initBorderRouter() => _run(
        _repository.initBorderRouter,
        'Thread border router init command sent.',
      );
  Future<void> deinitBorderRouter() => _run(
        _repository.deinitBorderRouter,
        'Thread border router deinit command sent.',
      );

  Future<void> _run(
      ThreadCommandOperation operation, String successMessage) async {
    state = const ThreadCommandState(submitting: true);
    final result = await operation();
    state = switch (result) {
      Success() => ThreadCommandState(message: successMessage, success: true),
      FailureResult(failure: final failure) =>
        ThreadCommandState(message: failure.message),
    };
  }
}
