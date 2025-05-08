import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dashboard/blocs/thread/ifconfig_status/ifconfig_status_bloc.dart';
import 'package:dashboard/blocs/thread/thread_status/thread_status_bloc.dart';
import 'package:dashboard/blocs/thread/thread_role/thread_role_bloc.dart';
import 'package:dashboard/blocs/wifi_sta_status/wifi_sta_status_bloc.dart';
import 'package:dashboard/blocs/temperature_set/temperature_set_bloc.dart';
import 'package:dashboard/widget/sidebar/websocket_connect_button_widget.dart';

import '../status_card_widget.dart';

class SideBarWidget extends StatelessWidget {
  final Color backgroundColor;
  final double width;

  const SideBarWidget({
    super.key,
    required this.backgroundColor,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: backgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20.0),
                    const WebsocketConnectButtonWidget(),
                    const SizedBox(height: 10.0),

                    StatusCardWidget<IfconfigStatusState>(
                      bloc: context.read<IfconfigStatusBloc>(),
                      isUpdated: (state) => state is IfconfigStatusUpdated,
                      extractStatus: (state) => (state as IfconfigStatusUpdated).status,
                      title: 'Ifconfig',
                      colorResolver: (status) {
                        switch (status.toLowerCase()) {
                          case 'enabled': return Colors.greenAccent;
                          case 'disabled': return Colors.redAccent;
                          default: return Colors.white;
                        }
                      },
                      formatter: (s) => s.toUpperCase(),
                    ),

                    const SizedBox(height: 10.0),

                    StatusCardWidget<ThreadRoleState>(
                      bloc: context.read<ThreadRoleBloc>(),
                      isUpdated: (state) => state is ThreadRoleUpdated,
                      extractStatus: (state) => (state as ThreadRoleUpdated).role,
                      title: 'Thread Role',
                      colorResolver: (role) {
                        switch (role.toLowerCase()) {
                          case 'leader': return Colors.greenAccent;
                          case 'router': return Colors.blueAccent;
                          case 'child': return Colors.orangeAccent;
                          case 'disabled': return Colors.redAccent;
                          default: return Colors.white;
                        }
                      },
                      formatter: (s) => s.toUpperCase(),
                    ),

                    const SizedBox(height: 10.0),

                    StatusCardWidget<ThreadStatusState>(
                      bloc: context.read<ThreadStatusBloc>(),
                      isUpdated: (state) => state is ThreadStatusUpdated,
                      extractStatus: (state) => (state as ThreadStatusUpdated).status,
                      title: 'Thread',
                      colorResolver: (status) {
                        switch (status.toLowerCase()) {
                          case 'attached': return Colors.greenAccent;
                          case 'detached': return Colors.redAccent;
                          default: return Colors.white;
                        }
                      },
                      formatter: (s) => s.toUpperCase(),
                    ),

                    const SizedBox(height: 10.0),

                    StatusCardWidget<WifiStaStatusState>(
                      bloc: context.read<WifiStaStatusBloc>(),
                      isUpdated: (state) => state is WifiStaStatusUpdated,
                      extractStatus: (state) => (state as WifiStaStatusUpdated).status,
                      title: 'Wifi STA',
                      colorResolver: (status) {
                        switch (status.toLowerCase()) {
                          case 'connected': return Colors.greenAccent;
                          case 'disconnect': return Colors.redAccent;
                          default: return Colors.white;
                        }
                      },
                      formatter: (s) => s.toUpperCase(),
                    ),

                    const SizedBox(height: 10.0),

                    StatusCardWidget<TemperatureSetState>(
                      bloc: context.read<TemperatureSetBloc>(),
                      isUpdated: (state) => state is TemperatureSetUpdated,
                      extractStatus: (state) {
                        final raw = (state as TemperatureSetUpdated).temperature;
                        return '${raw.substring(0, raw.length - 2)}.${raw.substring(raw.length - 2)} °C';
                      },
                      title: 'Temperature',
                      colorResolver: (_) => Colors.blueAccent,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
