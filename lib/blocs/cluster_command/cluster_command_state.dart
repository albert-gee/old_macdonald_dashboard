part of 'cluster_command_bloc.dart';

abstract class ClusterCommandState extends Equatable {
  const ClusterCommandState();

  @override
  List<Object> get props => [];
}

class ClusterCommandInitial extends ClusterCommandState {}

class ClusterCommandSuccess extends ClusterCommandState {}

class ClusterCommandFailure extends ClusterCommandState {
  final String error;

  const ClusterCommandFailure(this.error);

  @override
  List<Object> get props => [error];
}
