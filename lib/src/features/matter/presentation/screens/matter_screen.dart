import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_card.dart';
import 'package:dashboard/src/features/matter/presentation/widgets/matter_controller_init_form.dart';
import 'package:dashboard/src/features/matter/presentation/widgets/matter_pair_ble_thread_form.dart';
import 'package:dashboard/src/features/matter/presentation/widgets/matter_recent_events_card.dart';

class MatterScreen extends ConsumerWidget {
  const MatterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(matterCommandControllerProvider, (previous, next) {
      if (next.message != null && next.message != previous?.message) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message!)));
      }
    });
    final snapshot = ref.watch(orchestratorRuntimeControllerProvider).snapshot;
    final matter = snapshot?.matter;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            title: 'Matter Network',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Controller initialized: '
                  '${matter?.controllerInitialized ?? false}',
                ),
                Text(
                  'Commissioned nodes: '
                  '${matter?.commissionedNodes.length ?? 0}',
                ),
                for (final node in matter?.commissionedNodes ?? const [])
                  Text('${node.label ?? node.nodeId} (${node.nodeId})'),
                const SizedBox(height: AppDimensions.spacingM),
                const Text('Advanced raw Matter tools are in Developer.'),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),
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
          const MatterRecentEventsCard(),
        ],
      ),
    );
  }
}
