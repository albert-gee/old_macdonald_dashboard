import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/layout/app_page_scaffold.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_status.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_readiness.dart';
import 'package:dashboard/src/features/matter/presentation/widgets/matter_network_cards.dart';
import 'package:dashboard/src/features/thread/domain/entities/thread_readiness.dart';

class MatterScreen extends ConsumerStatefulWidget {
  const MatterScreen({super.key});

  @override
  ConsumerState<MatterScreen> createState() => _MatterScreenState();
}

class _MatterScreenState extends ConsumerState<MatterScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(deviceListControllerProvider.notifier).refresh(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
    final deviceListState = ref.watch(deviceListControllerProvider);
    final devices = deviceListState.devices;
    final matterEvents = ref.watch(matterEventControllerProvider).recentEvents;

    return AppPageScaffold(
      title: 'Matter Network',
      description:
          'Matter Device Network for pairing and managing chamber sensors and actuators.',
      children: [
        MatterReadinessCard(
          readiness: readiness,
          controllerInitialized: matter?.controllerInitialized ?? false,
        ),
        MatterPairChamberDeviceCard(readiness: readiness),
        MatterCommissionedDevicesCard(
          nodes: matter?.commissionedNodes ?? const [],
          registryDevices: devices,
        ),
        MatterRegistryMappingCard(
          nodes: matter?.commissionedNodes ?? const [],
          registryDevices: devices,
          registryLoading: deviceListState.loading,
          registryMessage: deviceListState.message,
        ),
        MatterRecentActivityCard(
          events: matterEvents,
          runtimeEvents: runtime.recentEvents,
        ),
        const MatterAdvancedDiagnosticsCard(),
      ],
    );
  }
}
