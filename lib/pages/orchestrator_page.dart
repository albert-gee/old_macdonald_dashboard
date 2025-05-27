import 'package:dashboard/widget/content/card_widget.dart';
import 'package:dashboard/widget/content/forms/websocket_connection_form_widget.dart';
import 'package:flutter/material.dart';

class OrchestratorPage extends StatelessWidget {
  const OrchestratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CardWidget(
          title: "WebSocket Connection",
          child: WebsocketConnectionFormWidget(),
        ),
      ],
    );
  }
}
