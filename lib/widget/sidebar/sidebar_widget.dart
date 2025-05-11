import 'package:flutter/material.dart';
import 'package:dashboard/widget/sidebar/websocket_connect_button_widget.dart';
import 'package:dashboard/widget/status_card_widget.dart';
import 'package:dashboard/blocs/status_card/status_card_bloc.dart';
import 'package:dashboard/blocs/status_card/status_card_state.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

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

                    StatusCardWidget<String>(
                      bloc: getIt<StatusCardBloc<String>>(instanceName: 'ifconfig'),
                      isUpdated: (state) => state is StatusCardUpdated<String>,
                      extractStatus: (state) => (state as StatusCardUpdated<String>).value,
                      title: 'Ifconfig',
                      colorResolver: (status) {
                        switch (status.toLowerCase()) {
                          case 'enabled':
                            return Colors.greenAccent;
                          case 'disabled':
                            return Colors.redAccent;
                          default:
                            return Colors.white;
                        }
                      },
                      formatter: (s) => s.toUpperCase(),
                    ),

                    const SizedBox(height: 10.0),

                    StatusCardWidget<String>(
                      bloc: getIt<StatusCardBloc<String>>(instanceName: 'thread_role'),
                      isUpdated: (state) => state is StatusCardUpdated<String>,
                      extractStatus: (state) => (state as StatusCardUpdated<String>).value,
                      title: 'Thread Role',
                      colorResolver: (role) {
                        switch (role.toLowerCase()) {
                          case 'leader':
                            return Colors.greenAccent;
                          case 'router':
                            return Colors.blueAccent;
                          case 'child':
                            return Colors.orangeAccent;
                          case 'disabled':
                            return Colors.redAccent;
                          default:
                            return Colors.white;
                        }
                      },
                      formatter: (s) => s.toUpperCase(),
                    ),

                    const SizedBox(height: 10.0),

                    StatusCardWidget<String>(
                      bloc: getIt<StatusCardBloc<String>>(instanceName: 'thread_status'),
                      isUpdated: (state) => state is StatusCardUpdated<String>,
                      extractStatus: (state) => (state as StatusCardUpdated<String>).value,
                      title: 'Thread',
                      colorResolver: (status) {
                        switch (status.toLowerCase()) {
                          case 'attached':
                            return Colors.greenAccent;
                          case 'detached':
                            return Colors.redAccent;
                          default:
                            return Colors.white;
                        }
                      },
                      formatter: (s) => s.toUpperCase(),
                    ),

                    const SizedBox(height: 10.0),

                    StatusCardWidget<String>(
                      bloc: getIt<StatusCardBloc<String>>(instanceName: 'wifi_sta'),
                      isUpdated: (state) => state is StatusCardUpdated<String>,
                      extractStatus: (state) => (state as StatusCardUpdated<String>).value,
                      title: 'Wifi STA',
                      colorResolver: (status) {
                        switch (status.toLowerCase()) {
                          case 'connected':
                            return Colors.greenAccent;
                          case 'disconnect':
                            return Colors.redAccent;
                          default:
                            return Colors.white;
                        }
                      },
                      formatter: (s) => s.toUpperCase(),
                    ),

                    const SizedBox(height: 10.0),

                    StatusCardWidget<String>(
                      bloc: getIt<StatusCardBloc<String>>(instanceName: 'temperature'),
                      isUpdated: (state) => state is StatusCardUpdated<String>,
                      extractStatus: (state) {
                        final raw = (state as StatusCardUpdated<String>).value;
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
