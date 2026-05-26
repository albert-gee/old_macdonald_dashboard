import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/layout/app_page_scaffold.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_status.dart';
import 'package:dashboard/src/features/wifi/domain/entities/wifi_network_readiness.dart';
import 'package:dashboard/src/features/wifi/presentation/widgets/wifi_network_cards.dart';

class WifiNetworkScreen extends ConsumerWidget {
  const WifiNetworkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runtime = ref.watch(orchestratorRuntimeControllerProvider);
    final snapshot = runtime.snapshot;
    final wifi = snapshot?.wifi;
    final connected =
        ref.watch(orchestratorConnectionControllerProvider).status ==
        WebSocketConnectionStatus.connected;
    final readiness = WifiNetworkReadiness.derive(
      connected: connected,
      hasSnapshot: snapshot != null,
      apRunning: wifi?.apRunning,
      staConfigured: wifi?.staConfigured,
      staConnected: wifi?.staConnected,
      staIp: wifi?.staIp,
      rssi: wifi?.rssi,
    );

    return AppPageScaffold(
      title: 'Wi-Fi Network',
      description:
          'Local Dashboard access and optional uplink connectivity for the Orchestrator.',
      children: [
        WifiReadinessCard(readiness: readiness),
        WifiLocalAccessCard(
          wifi: wifi,
          websocketClients: snapshot?.websocket.clients ?? 0,
        ),
        WifiUplinkCard(wifi: wifi, signalQuality: readiness.signalQuality),
        const WifiConnectCard(),
        WifiRecentActivityCard(events: runtime.recentEvents),
        WifiAdvancedDiagnosticsCard(wifi: wifi, websocket: snapshot?.websocket),
      ],
    );
  }
}
