part of 'cluster_command_bloc.dart';

abstract class ClusterCommandEvent extends Equatable {
  const ClusterCommandEvent();

  @override
  List<Object> get props => [];
}

class ClusterCommandRequested extends ClusterCommandEvent {
  final String destinationId;
  final int endpointId;
  final int clusterId;
  final int commandId;
  final String commandData;

  const ClusterCommandRequested({
    required this.destinationId,
    required this.endpointId,
    required this.clusterId,
    required this.commandId,
    required this.commandData,
  });

  @override
  List<Object> get props => [destinationId, endpointId, clusterId, commandId, commandData];
}

class ClusterCommandMessageReceived extends ClusterCommandEvent {
  final String message;

  const ClusterCommandMessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

class ClusterCommandReset extends ClusterCommandEvent {}
