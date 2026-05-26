import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_status.dart';
import 'package:dashboard/src/features/thread/domain/entities/thread_readiness.dart';
import 'package:dashboard/src/features/thread/presentation/widgets/thread_network_cards.dart';

class ThreadScreen extends ConsumerWidget {
  const ThreadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadStatusState = ref.watch(threadStatusControllerProvider);
    final oldStatus = threadStatusState.status;
    final runtime = ref.watch(orchestratorRuntimeControllerProvider);
    final snapshot = runtime.snapshot;
    final thread = snapshot?.thread;
    final connected =
        ref.watch(orchestratorConnectionControllerProvider).status ==
        WebSocketConnectionStatus.connected;
    final status = thread == null
        ? oldStatus
        : oldStatus.copyWith(
            stackRunning: thread.enabled,
            interfaceUp: thread.enabled,
            attached: thread.attached,
            role: thread.role,
            meshcopPublished: thread.datasetPresent,
          );
    final hasThreadData = thread != null || threadStatusState.hasData;
    final readiness = ThreadReadiness.derive(
      connected: connected,
      hasThreadData: hasThreadData,
      enabled: hasThreadData ? status.stackRunning : null,
      datasetPresent: hasThreadData ? status.meshcopPublished : null,
      attached: hasThreadData ? status.attached : null,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThreadReadinessCard(readiness: readiness),
          const SizedBox(height: AppDimensions.spacingL),
          ThreadNetworkStateCard(status: status, readiness: readiness),
          const SizedBox(height: AppDimensions.spacingL),
          ThreadDatasetSummaryCard(
            datasetPresent: status.meshcopPublished,
            dataset: status.activeDataset,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          ThreadOperatorActionsCard(status: status),
          const SizedBox(height: AppDimensions.spacingL),
          ThreadRecentEventsCard(events: runtime.recentEvents),
          const SizedBox(height: AppDimensions.spacingL),
          ThreadAdvancedDiagnosticsCard(addresses: status.addresses),
        ],
      ),
    );
  }
}
