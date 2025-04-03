part of 'ifconfig_status_bloc.dart';

abstract class IfconfigStatusState extends Equatable {
  const IfconfigStatusState();

  @override
  List<Object> get props => [];
}

class IfconfigStatusInitial extends IfconfigStatusState {}

class IfconfigStatusUpdated extends IfconfigStatusState {
  final String status;

  const IfconfigStatusUpdated(this.status);

  @override
  List<Object> get props => [status];
}