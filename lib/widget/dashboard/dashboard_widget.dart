import 'package:dashboard/blocs/websocket_connection/websocket_connection_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'forms/cluster_command_widget.dart';
import 'forms/command_form_widget.dart';
import 'forms/pair_ble_thread_widget.dart';
import 'forms/thread_dataset_init_form_widget.dart';
import 'forms/wifi_sta_connect_form_widget.dart';
import 'info/thread_dataset_active_widget.dart';

class DashboardWidget extends StatelessWidget {
  const DashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final WebsocketConnectionBloc websocketConnectionBloc =
        BlocProvider.of<WebsocketConnectionBloc>(context);

    return BlocBuilder<WebsocketConnectionBloc, WebsocketConnectionState>(
        bloc: websocketConnectionBloc,
        builder: (context, state) {
          if (state is WebsocketConnectionConnectedState) {
            return _buildDashboardWidget();
          } else if (state is WebsocketConnectionConnectingState) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Center(
              child: Text(
                'WebSocket not connected',
                style: TextStyle(color: Colors.red),
              ),
            );
          }
        });
  }

  Widget _buildDashboardWidget() {
    return Column(
      children: [

        // Message Form
        CommandFormWidget(),

        const SizedBox(height: 50.0),

        // Two-column layout for Thread widgets
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: ThreadDatasetInitFormWidget(),
            ),
            const SizedBox(width: 20.0),
            Expanded(
              flex: 1,
              child: ThreadDatasetActiveWidget(),
            ),
          ],
        ),
        const SizedBox(height: 50.0),

        // Two-column layout for Thread widgets
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: WifiStaConnectFormWidget(),
            ),
            const SizedBox(width: 20.0),
            Expanded(
              flex: 1,
              child: Container(),
            ),
          ],
        ),
        const SizedBox(height: 50.0),

        // PairBleThreadWidget
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: PairBleThreadWidget(),
            ),
            const SizedBox(width: 20.0),
            Expanded(
              flex: 1,
              child: ClusterCommandWidget(),
            ),
          ],
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }
}
