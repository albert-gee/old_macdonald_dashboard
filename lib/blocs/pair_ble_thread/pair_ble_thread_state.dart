part of 'pair_ble_thread_bloc.dart';

abstract class PairBleThreadState extends Equatable {
  const PairBleThreadState();

  @override
  List<Object> get props => [];
}

class PairBleThreadInitial extends PairBleThreadState {}

class PairBleThreadLoading extends PairBleThreadState {}

class PairBleThreadInProgress extends PairBleThreadState {
  final double progress;
  final String message;

  const PairBleThreadInProgress(this.progress, this.message);

  @override
  List<Object> get props => [progress, message];
}

class PairBleThreadSuccess extends PairBleThreadState {}

class PairBleThreadFailure extends PairBleThreadState {
  final String error;

  const PairBleThreadFailure(this.error);

  @override
  List<Object> get props => [error];
}