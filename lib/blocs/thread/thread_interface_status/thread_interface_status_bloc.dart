import 'package:flutter_bloc/flutter_bloc.dart';
import 'thread_interface_status_event.dart';
import 'thread_interface_status_state.dart';

class ThreadInterfaceStatusBloc extends Bloc<ThreadInterfaceStatusEvent, ThreadInterfaceStatusState> {
  ThreadInterfaceStatusBloc() : super(ThreadInterfaceStatusState.initial()) {
    on<ThreadInterfaceStatusUpdated>((event, emit) {
      emit(state.copyWith(isInterfaceUp: event.isInterfaceUp));
    });
  }
}
