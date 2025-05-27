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
          Color statusColor = Colors.white;
          IconData statusIcon = Icons.sync_disabled;

          if (state is WebsocketConnectionConnectedState) {
            statusColor = Colors.green;
            statusIcon = Icons.sync;
          } else if (state is WebsocketConnectionConnectingState) {
            statusColor = Colors.yellow;
            statusIcon = Icons.sync;
          }

          return Icon(
            statusIcon,
            color: statusColor,
          );
        });
  }
}
