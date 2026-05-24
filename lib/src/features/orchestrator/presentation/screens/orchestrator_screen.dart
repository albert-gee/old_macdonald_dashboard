import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
import 'package:dashboard/src/core/widgets/app_card.dart';
import 'package:dashboard/src/features/orchestrator/presentation/widgets/orchestrator_certificate_trust_card.dart';
import 'package:dashboard/src/features/orchestrator/presentation/widgets/orchestrator_pending_commands_card.dart';
import 'package:dashboard/src/features/orchestrator/presentation/widgets/orchestrator_recent_events_card.dart';
import 'package:dashboard/src/features/orchestrator/presentation/widgets/orchestrator_runtime_snapshot_card.dart';
import 'package:dashboard/src/features/orchestrator/presentation/widgets/websocket_connection_form.dart';

class OrchestratorScreen extends ConsumerWidget {
  const OrchestratorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(orchestratorConnectionControllerProvider);
    return SingleChildScrollView(
      child: Column(
        children: [
          AppCard(
            title: 'WebSocket Connection',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: ${connection.status.name}'),
                Text('Current URL: ${connection.url}'),
                const SizedBox(height: AppDimensions.spacingM),
                const WebsocketConnectionForm(),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingL),
          const OrchestratorCertificateTrustCard(),
          const SizedBox(height: AppDimensions.spacingL),
          const OrchestratorRuntimeSnapshotCard(),
          const SizedBox(height: AppDimensions.spacingL),
          const OrchestratorPendingCommandsCard(),
          const SizedBox(height: AppDimensions.spacingL),
          const OrchestratorRecentEventsCard(),
        ],
      ),
    );
  }
}
