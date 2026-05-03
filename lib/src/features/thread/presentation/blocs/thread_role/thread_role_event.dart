import 'package:equatable/equatable.dart';

abstract class ThreadRoleEvent extends Equatable {
  const ThreadRoleEvent();

  @override
  List<Object> get props => [];
}

class ThreadRoleUpdated extends ThreadRoleEvent {
  final String role;

  const ThreadRoleUpdated(this.role);

  @override
  List<Object> get props => [role];
}
