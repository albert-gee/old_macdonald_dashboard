import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_card.dart';
import 'package:dashboard/src/features/matter/presentation/widgets/matter_attribute_read_form.dart';
import 'package:dashboard/src/features/matter/presentation/widgets/matter_attribute_subscribe_form.dart';
import 'package:dashboard/src/features/matter/presentation/widgets/matter_cluster_command_form.dart';

class RawMatterToolsCard extends ConsumerWidget {
  const RawMatterToolsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clustersState = ref.watch(matterClusterControllerProvider);
    final clusters = clustersState.clusters;
    return AppCard(
      title: 'Raw Matter Tools',
      child: clustersState.loading
          ? const LinearProgressIndicator()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cluster Command',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                MatterClusterCommandForm(clusters: clusters),
                const SizedBox(height: AppDimensions.spacingL),
                Text(
                  'Read Attribute',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                MatterAttributeReadForm(clusters: clusters),
                const SizedBox(height: AppDimensions.spacingL),
                Text(
                  'Subscribe Attribute',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                MatterAttributeSubscribeForm(clusters: clusters),
              ],
            ),
    );
  }
}
