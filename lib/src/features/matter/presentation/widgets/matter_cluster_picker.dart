import 'package:flutter/material.dart';

import 'package:dashboard/src/features/matter/domain/entities/matter_cluster.dart';

class MatterClusterPicker extends StatelessWidget {
  final List<MatterCluster> clusters;
  final MatterCluster? value;
  final ValueChanged<MatterCluster?> onChanged;

  const MatterClusterPicker({
    super.key,
    required this.clusters,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<MatterCluster>(
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Cluster'),
      items: clusters
          .map(
            (cluster) => DropdownMenuItem(
              value: cluster,
              child: Text(
                '${cluster.name} (${cluster.id})',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Cluster is required.' : null,
    );
  }
}
