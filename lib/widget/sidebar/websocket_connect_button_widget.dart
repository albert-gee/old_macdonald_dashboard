import 'package:dashboard/blocs/websocket_connection/websocket_connection_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectButtonWidget extends StatelessWidget {
  const ConnectButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final WebsocketConnectionBloc websocketConnectionBloc =
        BlocProvider.of<WebsocketConnectionBloc>(context);

    return BlocBuilder<WebsocketConnectionBloc, WebsocketConnectionState>(
        bloc: websocketConnectionBloc,
        builder: (context, state) {
          String statusText = 'Disconnected';
          Color statusColor = Colors.grey;
          IconData statusIcon = Icons.signal_wifi_off;
          bool isConnected = false;

          if (state is WebsocketConnectionConnectedState) {
            statusText = 'Connected';
            statusColor = Colors.green;
            statusIcon = Icons.signal_wifi_4_bar;
            isConnected = true;
          } else if (state is WebsocketConnectionConnectingState) {
            statusText = 'Connecting...';
            statusColor = Colors.yellow;
            statusIcon = Icons.signal_wifi_4_bar;
          } else {
            statusText = 'Disconnected';
            statusColor = Colors.grey;
            statusIcon = Icons.signal_wifi_off;
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
              size: 70.0,
              color: statusColor,
            ),
          ],
        ),
        Text(
          statusText,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
      ],
    );
  }
}
