import 'package:dashboard/blocs/websocket_connection/websocket_connection_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WebsocketConnectButtonWidget extends StatelessWidget {
  const WebsocketConnectButtonWidget({super.key});

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
          bool isConnected = false;

          if (state is WebsocketConnectionConnectedState) {
            statusText = 'WebSocket';
            statusColor = Colors.green;
            statusIcon = Icons.sync;
            isConnected = true;
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
            child: GestureDetector(
              onTap: () {
                if (isConnected) {
                  print('Disconnecting from WebSocket...');
                  websocketConnectionBloc
                      .add(const WebsocketConnectionDisconnectingEvent());
                } else {
                  print('Connecting to WebSocket...');
                  websocketConnectionBloc
                      .add(const WebsocketConnectionConnectingEvent());
                }
              },
              child: _buildUi(
                statusColor: statusColor,
                statusIcon: statusIcon,
                statusText: statusText,
              ),
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
