import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/widgets/app_panel.dart';

class OrchestratorRuntimeSnapshotCard extends ConsumerWidget {
  final bool showContainer;

  const OrchestratorRuntimeSnapshotCard({super.key, this.showContainer = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(orchestratorRuntimeControllerProvider).snapshot;
    final content = snapshot == null
        ? const Text('No state_snapshot received yet.')
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wi-Fi: mode ${snapshot.wifi.mode}, AP '
                '${snapshot.wifi.apRunning ? 'running' : 'stopped'}, STA '
                '${snapshot.wifi.staConnected ? 'connected' : 'disconnected'}',
              ),
              Text('STA IP: ${snapshot.wifi.staIp ?? '-'}'),
              Text('RSSI: ${snapshot.wifi.rssi?.toString() ?? '-'}'),
              const SizedBox(height: 8),
              Text(
                'Thread: ${snapshot.thread.role}, enabled '
                '${snapshot.thread.enabled}, attached '
                '${snapshot.thread.attached}, dataset '
                '${snapshot.thread.datasetPresent}',
              ),
              const SizedBox(height: 8),
              Text(
                'Matter controller initialized: '
                '${snapshot.matter.controllerInitialized}',
              ),
              Text(
                'Commissioned nodes: '
                '${snapshot.matter.commissionedNodes.length}',
              ),
              const SizedBox(height: 8),
              Text('WebSocket clients: ${snapshot.websocket.clients}'),
            ],
          );
    if (!showContainer) return content;
    return AppPanel(
      title: 'Runtime Snapshot',
      tone: AppPanelTone.neutral,
      child: content,
    );
  }
}
