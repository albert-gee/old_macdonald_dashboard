import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/widgets/app_card.dart';

class WifiApScreen extends ConsumerWidget {
  const WifiApScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(orchestratorRuntimeControllerProvider).snapshot;
    final wifi = snapshot?.wifi;
    final websocket = snapshot?.websocket;
    return SingleChildScrollView(
      child: AppCard(
        title: 'Wi-Fi Runtime',
        child: wifi == null
            ? const Text('No state_snapshot received yet.')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AP running: ${wifi.apRunning}'),
                  Text('Mode: ${wifi.mode}'),
                  Text('STA configured: ${wifi.staConfigured}'),
                  Text('STA connected: ${wifi.staConnected}'),
                  Text('STA IP: ${wifi.staIp ?? '-'}'),
                  Text('RSSI: ${wifi.rssi?.toString() ?? '-'}'),
                  Text('WebSocket clients: ${websocket?.clients ?? 0}'),
                ],
              ),
      ),
    );
  }
}
