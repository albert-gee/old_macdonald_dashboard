import 'package:dashboard/blocs/websocket_connection/websocket_connection_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WebsocketConnectionIndicatorWidget extends StatelessWidget {
  const WebsocketConnectionIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final WebsocketConnectionBloc websocketConnectionBloc =
        BlocProvider.of<WebsocketConnectionBloc>(context);

    return BlocBuilder<WebsocketConnectionBloc, WebsocketConnectionState>(
        bloc: websocketConnectionBloc,
        builder: (context, state) {
          String statusText;
          Color statusColor = Colors.grey;
          IconData statusIcon = Icons.sync_disabled;

          if (state is WebsocketConnectionConnectedState) {
            statusText = 'WebSocket';
            statusColor = Colors.green;
            statusIcon = Icons.sync;
          } else if (state is WebsocketConnectionConnectingState) {
            statusText = 'Connecting...';
            statusColor = Colors.yellow;
            statusIcon = Icons.sync;
          } else {
            statusText = 'WebSocket';
            statusColor = Colors.grey;
            statusIcon = Icons.sync_disabled;
          }

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: _buildUi(
              statusColor: statusColor,
              statusIcon: statusIcon,
              statusText: statusText,
            ),
          );
        });
  }

  Widget _buildUi(
      {required Color statusColor,
      required IconData statusIcon,
      required String statusText}) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              statusIcon,
              size: 50.0,
              color: statusColor,
            ),
          ],
        ),
        Text(
          statusText,
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
      ],
    );
  }
}
