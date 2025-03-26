part of 'thread_dataset_active_bloc.dart';

abstract class ThreadDatasetActiveState extends Equatable {
  const ThreadDatasetActiveState();

  @override
  List<Object> get props => [];
}

class ThreadDatasetActiveInitial extends ThreadDatasetActiveState {}

class ThreadDatasetActiveLoaded extends ThreadDatasetActiveState {
  final Map<String, dynamic> dataset;

  const ThreadDatasetActiveLoaded(this.dataset);

  @override
  List<Object> get props => [dataset];
}