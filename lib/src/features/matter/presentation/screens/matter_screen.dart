import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_status.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_readiness.dart';
import 'package:dashboard/src/features/matter/presentation/widgets/matter_network_cards.dart';
import 'package:dashboard/src/features/thread/domain/entities/thread_readiness.dart';

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

    final runtime = ref.watch(orchestratorRuntimeControllerProvider);
    final snapshot = runtime.snapshot;
    final thread = snapshot?.thread;
    final matter = snapshot?.matter;
    final connected =
        ref.watch(orchestratorConnectionControllerProvider).status ==
        WebSocketConnectionStatus.connected;
    final threadReadiness = ThreadReadiness.derive(
      connected: connected,
      hasThreadData: thread != null,
      enabled: thread?.enabled,
      datasetPresent: thread?.datasetPresent,
      attached: thread?.attached,
    );
    final readiness = MatterReadiness.derive(
      connected: connected,
      hasSnapshot: snapshot != null,
      threadReadiness: threadReadiness,
      controllerInitialized: matter?.controllerInitialized,
      commissionedNodeCount: matter?.commissionedNodes.length,
    );
    final devices = ref.watch(deviceListControllerProvider).devices;
    final matterEvents = ref.watch(matterEventControllerProvider).recentEvents;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MatterReadinessCard(
            readiness: readiness,
            controllerInitialized: matter?.controllerInitialized ?? false,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          MatterPairChamberDeviceCard(readiness: readiness),
          const SizedBox(height: AppDimensions.spacingL),
          MatterCommissionedDevicesCard(
            nodes: matter?.commissionedNodes ?? const [],
            registryDevices: devices,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          MatterRegistryMappingCard(
            nodes: matter?.commissionedNodes ?? const [],
            registryDevices: devices,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          MatterRecentActivityCard(
            events: matterEvents,
            runtimeEvents: runtime.recentEvents,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          const MatterAdvancedDiagnosticsCard(),
        ],
      ),
    );
  }
}
