import 'package:flutter/material.dart';

import 'package:dashboard/src/core/widgets/app_card.dart';
import 'package:dashboard/src/features/orchestrator/presentation/widgets/websocket_connection_form.dart';

class OrchestratorScreen extends StatelessWidget {
  const OrchestratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: AppCard(
        title: 'WebSocket Connection',
        child: WebsocketConnectionForm(),
      ),
    );
  }
}
