import 'package:equatable/equatable.dart';

abstract class ThreadStackStatusEvent extends Equatable {
  const ThreadStackStatusEvent();
  @override
  List<Object> get props => [];
}

class ThreadStackStatusUpdated extends ThreadStackStatusEvent {
  final bool isRunning;

  const ThreadStackStatusUpdated(this.isRunning);

  @override
  List<Object> get props => [isRunning];
}
