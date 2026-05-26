import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_panel.dart';
import 'package:dashboard/src/features/matter/presentation/widgets/matter_attribute_read_form.dart';
import 'package:dashboard/src/features/matter/presentation/widgets/matter_attribute_subscribe_form.dart';
import 'package:dashboard/src/features/matter/presentation/widgets/matter_cluster_command_form.dart';

class RawMatterToolsCard extends ConsumerWidget {
  const RawMatterToolsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clustersState = ref.watch(matterClusterControllerProvider);
    final clusters = clustersState.clusters;
    return AppPanel(
      title: 'Raw Matter diagnostics',
      subtitle:
          'Low-level Matter cluster, attribute, and subscription tools for troubleshooting.',
      tone: AppPanelTone.neutral,
      child: clustersState.loading
          ? const LinearProgressIndicator()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text('Invoke cluster command'),
                  subtitle: const Text('Invoke a raw Matter cluster command.'),
                  children: [
                    MatterClusterCommandForm(clusters: clusters),
                    const SizedBox(height: AppDimensions.spacingM),
                  ],
                ),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text('Read attribute'),
                  subtitle: const Text('Read a raw Matter attribute.'),
                  children: [
                    MatterAttributeReadForm(clusters: clusters),
                    const SizedBox(height: AppDimensions.spacingM),
                  ],
                ),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text('Subscribe attribute'),
                  subtitle: const Text(
                    'Subscribe to raw Matter attribute reports.',
                  ),
                  children: [
                    MatterAttributeSubscribeForm(clusters: clusters),
                    const SizedBox(height: AppDimensions.spacingM),
                  ],
                ),
              ],
            ),
    );
  }
}
