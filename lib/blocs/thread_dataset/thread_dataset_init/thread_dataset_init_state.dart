part of 'thread_dataset_init_bloc.dart';

sealed class ThreadDatasetInitState extends Equatable {
  const ThreadDatasetInitState();

  @override
  List<Object?> get props => [];
}

final class ThreadDatasetInitInitialState extends ThreadDatasetInitState {
  const ThreadDatasetInitInitialState();
}

final class ThreadDatasetInitLoadingState extends ThreadDatasetInitState {
  const ThreadDatasetInitLoadingState();
}

final class ThreadDatasetInitSuccessState extends ThreadDatasetInitState {
  const ThreadDatasetInitSuccessState();
}

final class ThreadDatasetInitFailureState extends ThreadDatasetInitState {
  final String error;

  const ThreadDatasetInitFailureState(this.error);

  @override
  List<Object> get props => [error];
}
