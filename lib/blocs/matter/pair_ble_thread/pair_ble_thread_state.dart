part of 'pair_ble_thread_bloc.dart';

abstract class PairBleThreadState extends Equatable {
  const PairBleThreadState();

  @override
  List<Object> get props => [];
}

class PairBleThreadInitial extends PairBleThreadState {}

class PairBleThreadSuccess extends PairBleThreadState {}

class PairBleThreadFailure extends PairBleThreadState {
  final String error;

  const PairBleThreadFailure(this.error);

  @override
  List<Object> get props => [error];
}