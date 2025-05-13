import 'package:equatable/equatable.dart';

class ThreadStackStatusState extends Equatable {
  final bool isRunning;

  const ThreadStackStatusState({required this.isRunning});

  factory ThreadStackStatusState.initial() => const ThreadStackStatusState(isRunning: false);

  ThreadStackStatusState copyWith({bool? isRunning}) {
    return ThreadStackStatusState(isRunning: isRunning ?? this.isRunning);
  }

  @override
  List<Object> get props => [isRunning];
}
