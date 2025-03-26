import 'package:dashboard/blocs/thread/thread_role/thread_role_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ThreadRoleWidget extends StatelessWidget {
  const ThreadRoleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThreadRoleBloc, ThreadRoleState>(
      builder: (context, state) {
        final role = state is ThreadRoleUpdated ? state.role : 'Unknown';

        return Container(
          margin: const EdgeInsets.all(10.0),
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xff202020), // Dark card background
                Color(0xff303030), // Slightly lighter card background
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 7.0,
                spreadRadius: 2.5,
                offset: const Offset(0, 1.0),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              const Text(
                'Thread Role',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.0,
                ),
              ),
              const SizedBox(height: 5.0),
              // Role Value
              Text(
                _formatRole(role),
                style: TextStyle(
                  color: _getRoleColor(role),
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatRole(String role) {
    return role.toUpperCase();
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'leader':
        return Colors.greenAccent;
      case 'router':
        return Colors.blueAccent;
      case 'child':
        return Colors.orangeAccent;
      case 'disabled':
        return Colors.redAccent;
      default:
        return Colors.white;
    }
  }
}