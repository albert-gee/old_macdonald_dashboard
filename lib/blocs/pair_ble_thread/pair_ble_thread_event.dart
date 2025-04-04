part of 'pair_ble_thread_bloc.dart';

abstract class PairBleThreadEvent extends Equatable {
  const PairBleThreadEvent();

  @override
  List<Object> get props => [];
}

class PairBleThreadRequested extends PairBleThreadEvent {
  final String nodeId;
  final String setupCode; // Changed from 'pin' to 'setup_code'
  final String discriminator;

  const PairBleThreadRequested({
    required this.nodeId,
    required this.setupCode,
    required this.discriminator,
  });

  @override
  List<Object> get props => [nodeId, setupCode, discriminator];
}

class PairBleThreadMessageReceived extends PairBleThreadEvent {
  final String message;

  const PairBleThreadMessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

class PairBleThreadReset extends PairBleThreadEvent {}