import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'thread_dataset_active_event.dart';
part 'thread_dataset_active_state.dart';

class ThreadDatasetActiveBloc extends Bloc<ThreadDatasetActiveEvent, ThreadDatasetActiveState> {
  ThreadDatasetActiveBloc() : super(ThreadDatasetActiveInitial()) {
    on<LoadThreadDataset>(_onLoadThreadDataset);
    on<ClearThreadDataset>(_onClearThreadDataset);
  }

  Future<void> _onLoadThreadDataset(
      LoadThreadDataset event,
      Emitter<ThreadDatasetActiveState> emit,
      ) async {
    emit(ThreadDatasetActiveLoaded(event.dataset));
  }

  Future<void> _onClearThreadDataset(
      ClearThreadDataset event,
      Emitter<ThreadDatasetActiveState> emit,
      ) async {
    emit(ThreadDatasetActiveInitial());
  }
}