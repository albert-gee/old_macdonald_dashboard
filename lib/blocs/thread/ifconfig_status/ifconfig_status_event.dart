part of 'ifconfig_status_bloc.dart';

abstract class IfconfigStatusEvent extends Equatable {
  const IfconfigStatusEvent();

  @override
  List<Object> get props => [];
}

class IfconfigStatusChanged extends IfconfigStatusEvent {
  final String status;

  const IfconfigStatusChanged(this.status);

  @override
  List<Object> get props => [status];
}