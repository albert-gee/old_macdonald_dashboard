import 'package:flutter_bloc/flutter_bloc.dart';
import 'thread_role_event.dart';
import 'thread_role_state.dart';

class ThreadRoleBloc extends Bloc<ThreadRoleEvent, ThreadRoleState> {
  ThreadRoleBloc() : super(ThreadRoleState.initial()) {
    on<ThreadRoleUpdated>((event, emit) {
      emit(state.copyWith(role: event.role));
    });
  }
}
