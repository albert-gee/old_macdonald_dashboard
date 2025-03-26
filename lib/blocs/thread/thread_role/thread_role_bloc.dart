import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'thread_role_event.dart';
part 'thread_role_state.dart';

class ThreadRoleBloc extends Bloc<ThreadRoleEvent, ThreadRoleState> {
  ThreadRoleBloc() : super(ThreadRoleInitial()) {
    on<ThreadRoleChanged>(_onRoleChanged);
  }

  Future<void> _onRoleChanged(
      ThreadRoleChanged event,
      Emitter<ThreadRoleState> emit,
      ) async {
    emit(ThreadRoleUpdated(event.role));
  }
}