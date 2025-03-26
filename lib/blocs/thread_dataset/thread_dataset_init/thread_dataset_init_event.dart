part of 'thread_dataset_init_bloc.dart';

sealed class ThreadDatasetInitEvent extends Equatable {
  const ThreadDatasetInitEvent();
}

final class ThreadDatasetInitSendEvent extends ThreadDatasetInitEvent {
  final Map<String, dynamic> dataset;

  const ThreadDatasetInitSendEvent(this.dataset);

  @override
  List<Object> get props => [dataset];
}
