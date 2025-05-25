import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:dashboard/services/i_thread_command_service.dart';
import 'thread_dataset_init_form_event.dart';
import 'thread_dataset_init_form_state.dart';

/// Bloc for handling Thread Dataset initialization form submission.
class ThreadDatasetInitFormBloc extends Bloc<ThreadDatasetInitFormEvent, ThreadDatasetInitFormState> {
  final IThreadCommandService _threadCommandService;

  ThreadDatasetInitFormBloc({IThreadCommandService? threadCommandService})
      : _threadCommandService = threadCommandService ?? GetIt.I<IThreadCommandService>(),
        super(ThreadDatasetInitFormInitial()) {
    on<ThreadDatasetInitSubmitted>(_handleSubmitted);
  }

  /// Handles the [ThreadDatasetInitSubmitted] event.
  ///
  /// Emits a submitting state, calls the service, and then emits success or failure.
  Future<void> _handleSubmitted(
      ThreadDatasetInitSubmitted event,
      Emitter<ThreadDatasetInitFormState> emit,
      ) async {
    emit(ThreadDatasetInitFormSubmitting());

    try {
      await _threadCommandService.sendThreadDatasetInitCommand(
        channel: event.channel,
        panId: event.panId,
        networkName: event.networkName,
        extendedPanId: event.extendedPanId,
        meshLocalPrefix: event.meshLocalPrefix,
        networkKey: event.networkKey,
        pskc: event.pskc,
      );
      emit(ThreadDatasetInitFormSuccess());
    } catch (error) {
      emit(ThreadDatasetInitFormFailure(error.toString()));
    }
  }
}
