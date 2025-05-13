import 'package:flutter_bloc/flutter_bloc.dart';
import 'thread_meshcop_service_status_event.dart';
import 'thread_meshcop_service_status_state.dart';

class ThreadMeshcopServiceStatusBloc extends Bloc<ThreadMeshcopServiceStatusEvent, ThreadMeshcopServiceStatusState> {
  ThreadMeshcopServiceStatusBloc() : super(ThreadMeshcopServiceStatusState.initial()) {
    on<ThreadMeshcopServiceStatusUpdated>((event, emit) {
      emit(state.copyWith(isPublished: event.isPublished));
    });
  }
}
