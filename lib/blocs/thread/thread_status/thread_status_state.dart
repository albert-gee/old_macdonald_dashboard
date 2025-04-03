part of 'thread_status_bloc.dart';

abstract class ThreadStatusState extends Equatable {
  const ThreadStatusState();

  @override
  List<Object> get props => [];
}

class ThreadStatusInitial extends ThreadStatusState {}

class ThreadStatusUpdated extends ThreadStatusState {
  final String status;

  const ThreadStatusUpdated(this.status);

  @override
  List<Object> get props => [status];
}