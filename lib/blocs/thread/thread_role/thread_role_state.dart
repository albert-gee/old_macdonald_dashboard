import 'package:equatable/equatable.dart';

class ThreadRoleState extends Equatable {
  final String role;

  const ThreadRoleState({required this.role});

  factory ThreadRoleState.initial() => const ThreadRoleState(role: 'unknown');

  ThreadRoleState copyWith({String? role}) {
    return ThreadRoleState(role: role ?? this.role);
  }

  @override
  List<Object> get props => [role];
}
