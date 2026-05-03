import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_card.dart';
import 'package:dashboard/src/features/matter/presentation/widgets/matter_attribute_read_form.dart';
import 'package:dashboard/src/features/matter/presentation/widgets/matter_attribute_subscribe_form.dart';
import 'package:dashboard/src/features/matter/presentation/widgets/matter_cluster_command_form.dart';
import 'package:dashboard/src/features/matter/presentation/widgets/matter_controller_init_form.dart';
import 'package:dashboard/src/features/matter/presentation/widgets/matter_pair_ble_thread_form.dart';
import 'package:dashboard/src/features/matter/presentation/widgets/matter_recent_events_card.dart';

class MatterScreen extends ConsumerWidget {
  const MatterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(matterCommandControllerProvider, (previous, next) {
      if (next.message != null && next.message != previous?.message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message!)),
        );
      }
    });
    final clustersState = ref.watch(matterClusterControllerProvider);
    final clusters = clustersState.clusters;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppCard(
            title: 'Controller Init',
            child: MatterControllerInitForm(),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          const AppCard(
            title: 'Pair BLE Thread',
            child: MatterPairBleThreadForm(),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          AppCard(
            title: 'Cluster Command',
            child: clustersState.loading
                ? const LinearProgressIndicator()
                : MatterClusterCommandForm(clusters: clusters),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          AppCard(
            title: 'Read Attribute',
            child: clustersState.loading
                ? const LinearProgressIndicator()
                : MatterAttributeReadForm(clusters: clusters),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          AppCard(
            title: 'Subscribe Attribute',
            child: clustersState.loading
                ? const LinearProgressIndicator()
                : MatterAttributeSubscribeForm(clusters: clusters),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          if (clustersState.message != null)
            Text(
              clustersState.message!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const MatterRecentEventsCard(),
        ],
      ),
    );
  }
}
