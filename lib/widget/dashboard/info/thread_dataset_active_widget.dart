import 'package:dashboard/blocs/thread_dataset/thread_dataset_active/thread_dataset_active_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ThreadDatasetActiveWidget extends StatelessWidget {
  const ThreadDatasetActiveWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThreadDatasetActiveBloc, ThreadDatasetActiveState>(
      builder: (context, state) {
        if (state is ThreadDatasetActiveLoaded) {
          return _buildDatasetView(state.dataset);
        }
        return const SizedBox.shrink(); // Show nothing when no dataset
      },
    );
  }

  Widget _buildDatasetView(Map<String, dynamic> dataset) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.blueGrey.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active Thread Dataset',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildDatasetItem('Active Timestamp', dataset['active_timestamp']),
          _buildDatasetItem('Pending Timestamp', dataset['pending_timestamp']),
          _buildDatasetItem('Network Key', dataset['network_key']),
          _buildDatasetItem('Network Name', dataset['network_name']),
          _buildDatasetItem('Extended PAN ID', dataset['extended_pan_id']),
          _buildDatasetItem('Mesh Local Prefix', dataset['mesh_local_prefix']),
          _buildDatasetItem('Delay Timer', dataset['delay']),
          _buildDatasetItem('PAN ID', dataset['pan_id']),
          _buildDatasetItem('Channel', dataset['channel']),
          _buildDatasetItem('Wake-up Channel', dataset['wakeup_channel']),
          _buildDatasetItem('PSKc', dataset['pskc']),
          // These fields aren't in your JSON, so they'll show "Not set"
          _buildDatasetItem('Security Policy', _formatSecurityPolicy(dataset['security_policy'])),
          _buildDatasetItem('Channel Mask', dataset['channel_mask']),
          _buildDatasetItem('Components', _formatComponents(dataset['components'])),
        ],
      ),
    );
  }

  Widget _buildDatasetItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value?.toString() ?? 'Not set',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatSecurityPolicy(dynamic policy) {
    if (policy == null) return 'Not set';
    if (policy is Map) {
      return 'Rotation Time: ${policy['rotationTime']}, Flags: ${policy['flags']}';
    }
    return policy.toString();
  }

  String _formatComponents(dynamic components) {
    if (components == null) return 'Not set';
    if (components is Map) {
      return components.entries
          .where((e) => e.value == true)
          .map((e) => e.key)
          .join(', ');
    }
    return components.toString();
  }
}