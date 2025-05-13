part of 'subscribe_attribute_command_bloc.dart';

abstract class SubscribeAttributeCommandEvent extends Equatable {
  const SubscribeAttributeCommandEvent();

  @override
  List<Object> get props => [];
}

class SubscribeAttributeCommandRequested extends SubscribeAttributeCommandEvent {
  final String nodeId;
  final int endpointId;
  final int clusterId;
  final int attributeId;
  final int minInterval;
  final int maxInterval;
  final bool autoResubscribe;

  const SubscribeAttributeCommandRequested({
    required this.nodeId,
    required this.endpointId,
    required this.clusterId,
    required this.attributeId,
    required this.minInterval,
    required this.maxInterval,
    required this.autoResubscribe,
  });

  @override
  List<Object> get props => [
    nodeId,
    endpointId,
    clusterId,
    attributeId,
    minInterval,
    maxInterval,
    autoResubscribe,
  ];
}

class SubscribeAttributeCommandMessageReceived extends SubscribeAttributeCommandEvent {
  final String message;

  const SubscribeAttributeCommandMessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

class SubscribeAttributeCommandReset extends SubscribeAttributeCommandEvent {}
