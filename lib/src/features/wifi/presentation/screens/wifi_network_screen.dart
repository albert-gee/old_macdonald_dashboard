import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/theme/app_dimensions.dart';
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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WifiReadinessCard(readiness: readiness),
          const SizedBox(height: AppDimensions.spacingL),
          WifiLocalAccessCard(
            wifi: wifi,
            websocketClients: snapshot?.websocket.clients ?? 0,
          ),
          const SizedBox(height: AppDimensions.spacingL),
          WifiUplinkCard(wifi: wifi, signalQuality: readiness.signalQuality),
          const SizedBox(height: AppDimensions.spacingL),
          const WifiConnectCard(),
          const SizedBox(height: AppDimensions.spacingL),
          WifiRecentActivityCard(events: runtime.recentEvents),
          const SizedBox(height: AppDimensions.spacingL),
          WifiAdvancedDiagnosticsCard(
            wifi: wifi,
            websocket: snapshot?.websocket,
          ),
        ],
      ),
    );
  }
}
