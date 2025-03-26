part of 'thread_role_bloc.dart';

abstract class ThreadRoleState extends Equatable {
  const ThreadRoleState();

  @override
  List<Object> get props => [];
}

class ThreadRoleInitial extends ThreadRoleState {}

class ThreadRoleUpdated extends ThreadRoleState {
  final String role;

  const ThreadRoleUpdated(this.role);

  @override
  List<Object> get props => [role];
}