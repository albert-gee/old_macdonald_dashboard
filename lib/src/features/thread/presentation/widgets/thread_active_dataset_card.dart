import 'package:flutter/material.dart';

import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_card.dart';
import 'package:dashboard/src/features/thread/domain/entities/thread_active_dataset.dart';

class ThreadActiveDatasetCard extends StatelessWidget {
  final ThreadActiveDataset dataset;

  const ThreadActiveDatasetCard({super.key, required this.dataset});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: 'Active Dataset',
      child: dataset.isEmpty
          ? const Text('No active dataset received yet.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('Active timestamp', '${dataset.activeTimestamp}'),
                _row('Network name', dataset.networkName),
                _row('Extended PAN ID', dataset.extendedPanId),
                _row('Mesh-local prefix', dataset.meshLocalPrefix),
                _row('PAN ID', '${dataset.panId}'),
                _row('Channel', '${dataset.channel}'),
              ],
            ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      child: Text('$label: ${value.isEmpty ? '-' : value}'),
    );
  }
}
