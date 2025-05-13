import 'package:flutter_bloc/flutter_bloc.dart';
import 'thread_stack_status_event.dart';
import 'thread_stack_status_state.dart';

class ThreadStackStatusBloc extends Bloc<ThreadStackStatusEvent, ThreadStackStatusState> {
  ThreadStackStatusBloc() : super(ThreadStackStatusState.initial()) {
    on<ThreadStackStatusUpdated>((event, emit) {
      emit(state.copyWith(isRunning: event.isRunning));
    });
  }
}
