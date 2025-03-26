part of 'thread_role_bloc.dart';

abstract class ThreadRoleEvent extends Equatable {
  const ThreadRoleEvent();

  @override
  List<Object> get props => [];
}

class ThreadRoleChanged extends ThreadRoleEvent {
  final String role;

  const ThreadRoleChanged(this.role);

  @override
  List<Object> get props => [role];
}