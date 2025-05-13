import 'package:flutter_bloc/flutter_bloc.dart';
import 'thread_active_dataset_event.dart';
import 'thread_active_dataset_state.dart';

class ThreadActiveDatasetBloc extends Bloc<ThreadActiveDatasetUpdated, ThreadActiveDatasetState> {
  ThreadActiveDatasetBloc() : super(ThreadActiveDatasetState.initial()) {
    on<ThreadActiveDatasetUpdated>((event, emit) {
      emit(ThreadActiveDatasetState(
        activeTimestamp: event.activeTimestamp,
        networkName: event.networkName,
        extendedPanId: event.extendedPanId,
        meshLocalPrefix: event.meshLocalPrefix,
        panId: event.panId,
        channel: event.channel,
      ));
    });
  }
}
