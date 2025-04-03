import 'package:dashboard/blocs/thread/thread_status/thread_status_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThreadStatusWidget extends StatelessWidget {
  const ThreadStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThreadStatusBloc, ThreadStatusState>(
      builder: (context, state) {
        if (state is !ThreadStatusUpdated) {
          return Container();
        } else {
          // Extract the status from the state
          final status = state.status;
          return _buildStatusCard(status);
        }
      },
    );
  }

  Widget _buildStatusCard(String status) {

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
            'Thread',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13.0,
            ),
          ),
          const SizedBox(height: 5.0),
          // status Value
          Text(
            _formatStatus(status),
            style: TextStyle(
              color: _getStatusColor(status),
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    return status.toUpperCase();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'attached':
        return Colors.greenAccent;
      case 'detached':
        return Colors.redAccent;
      default:
        return Colors.white;
    }
  }
}