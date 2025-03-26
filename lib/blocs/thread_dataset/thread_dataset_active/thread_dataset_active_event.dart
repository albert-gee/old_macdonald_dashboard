part of 'thread_dataset_active_bloc.dart';

abstract class ThreadDatasetActiveEvent extends Equatable {
  const ThreadDatasetActiveEvent();

  @override
  List<Object> get props => [];
}

class LoadThreadDataset extends ThreadDatasetActiveEvent {
  final Map<String, dynamic> dataset;

  const LoadThreadDataset(this.dataset);

  @override
  List<Object> get props => [dataset];
}

class ClearThreadDataset extends ThreadDatasetActiveEvent {}