import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../services/i_thread_command_service.dart';
import 'thread_dataset_init_form_event.dart';
import 'thread_dataset_init_form_state.dart';

class ThreadDatasetInitFormBloc extends Bloc<ThreadDatasetInitFormEvent, ThreadDatasetInitFormState> {
  final IThreadCommandService _threadCommandService = GetIt.instance<IThreadCommandService>();

  ThreadDatasetInitFormBloc() : super(ThreadDatasetInitFormInitial()) {
    on<ThreadDatasetInitSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
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
    } catch (e) {
      emit(ThreadDatasetInitFormFailure(e.toString()));
    }
  }
}
