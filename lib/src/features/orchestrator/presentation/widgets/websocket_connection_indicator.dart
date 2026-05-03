import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_status.dart';

class WebsocketConnectionIndicator extends ConsumerWidget {
  const WebsocketConnectionIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(
      orchestratorConnectionControllerProvider.select((state) => state.status),
    );
    final colorScheme = Theme.of(context).colorScheme;
    final color = switch (status) {
      WebSocketConnectionStatus.connected => colorScheme.primary,
      WebSocketConnectionStatus.connecting => colorScheme.tertiary,
      WebSocketConnectionStatus.disconnected => colorScheme.error,
    };

    return Icon(Icons.circle, color: color, size: 12);
  }
}
