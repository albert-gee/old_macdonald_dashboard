part of 'read_attribute_command_bloc.dart';

abstract class ReadAttributeCommandEvent extends Equatable {
  const ReadAttributeCommandEvent();

  @override
  List<Object> get props => [];
}

class ReadAttributeCommandRequested extends ReadAttributeCommandEvent {
  final String nodeId;
  final int endpointId;
  final int clusterId;
  final int attributeId;

  const ReadAttributeCommandRequested({
    required this.nodeId,
    required this.endpointId,
    required this.clusterId,
    required this.attributeId,
  });

  @override
  List<Object> get props => [nodeId, endpointId, clusterId, attributeId];
}

class ReadAttributeCommandMessageReceived extends ReadAttributeCommandEvent {
  final String message;

  const ReadAttributeCommandMessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

class ReadAttributeCommandReset extends ReadAttributeCommandEvent {}
