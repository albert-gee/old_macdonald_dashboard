import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/thread/domain/entities/thread_dataset_init_request.dart';
import 'package:dashboard/src/features/thread/domain/repositories/thread_command_repository.dart';
import 'thread_dataset_init_state.dart';

final class ThreadDatasetInitController
    extends StateNotifier<ThreadDatasetInitState> {
  final ThreadCommandRepository _repository;

  ThreadDatasetInitController({required ThreadCommandRepository repository})
      : _repository = repository,
        super(const ThreadDatasetInitState());

  Future<void> submit(ThreadDatasetInitRequest request) async {
    state = const ThreadDatasetInitState(submitting: true);
    final result = await _repository.initDataset(request);
    state = switch (result) {
      Success() => const ThreadDatasetInitState(
          message: 'Thread dataset init command sent.',
          success: true,
        ),
      FailureResult(failure: final failure) =>
        ThreadDatasetInitState(message: failure.message),
    };
  }
}
