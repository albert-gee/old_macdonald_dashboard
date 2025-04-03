import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'thread_status_event.dart';
part 'thread_status_state.dart';

class ThreadStatusBloc extends Bloc<ThreadStatusEvent, ThreadStatusState> {
  ThreadStatusBloc() : super(ThreadStatusInitial()) {
    on<ThreadStatusChanged>(_onStatusChanged);
  }

  Future<void> _onStatusChanged(
      ThreadStatusChanged event,
      Emitter<ThreadStatusState> emit,
      ) async {
    emit(ThreadStatusUpdated(event.status));
  }
}