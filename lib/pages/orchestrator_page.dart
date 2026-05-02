import 'package:dashboard/widget/content/forms/websocket_connection_form_widget.dart';
import 'package:dashboard/services/i_orchestrator_url_storage.dart';
import 'package:dashboard/src/core/widgets/card_widget.dart';
import 'package:flutter/material.dart';

class OrchestratorPage extends StatelessWidget {
  final IOrchestratorUrlStorage urlStorage;

  const OrchestratorPage({
    super.key,
    required this.urlStorage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CardWidget(
          title: "WebSocket Connection",
          child: WebsocketConnectionFormWidget(urlStorage: urlStorage),
        ),
      ],
    );
  }
}
