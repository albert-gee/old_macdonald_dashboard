part of 'thread_status_bloc.dart';

abstract class ThreadStatusEvent extends Equatable {
  const ThreadStatusEvent();

  @override
  List<Object> get props => [];
}

class ThreadStatusChanged extends ThreadStatusEvent {
  final String status;

  const ThreadStatusChanged(this.status);

  @override
  List<Object> get props => [status];
}