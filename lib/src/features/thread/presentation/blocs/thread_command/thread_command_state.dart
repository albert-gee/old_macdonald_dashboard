import 'package:equatable/equatable.dart';

abstract class ThreadCommandState extends Equatable {
  const ThreadCommandState();

  @override
  List<Object?> get props => [];
}

class ThreadCommandInitial extends ThreadCommandState {
  const ThreadCommandInitial();
}

class ThreadCommandInProgress extends ThreadCommandState {
  const ThreadCommandInProgress();
}

class ThreadCommandSuccess extends ThreadCommandState {
  final String message;

  const ThreadCommandSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ThreadCommandFailure extends ThreadCommandState {
  final String message;

  const ThreadCommandFailure(this.message);

  @override
  List<Object?> get props => [message];
}
