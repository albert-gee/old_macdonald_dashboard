import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'blocs/side_menu/side_menu_cubit.dart';
import 'layout.dart';
import 'websocket/websocket_client.dart';
import 'websocket/websocket_message_parser.dart';

import 'blocs/thread/thread_active_dataset/thread_active_dataset_bloc.dart';
import 'blocs/thread/thread_address/thread_address_bloc.dart';
import 'blocs/thread/thread_attachment_status/thread_attachment_status_bloc.dart';
import 'blocs/thread/thread_dataset_init_form/thread_dataset_init_form_bloc.dart';
import 'blocs/thread/thread_interface_status/thread_interface_status_bloc.dart';
import 'blocs/thread/thread_meshcop_service_status/thread_meshcop_service_status_bloc.dart';
import 'blocs/thread/thread_role/thread_role_bloc.dart';
import 'blocs/thread/thread_stack_status/thread_stack_status_bloc.dart';
import 'blocs/websocket_connection/websocket_connection_bloc.dart';
import 'blocs/wifi_sta_connect/wifi_sta_connect_bloc.dart';

class DashboardApp extends StatelessWidget {
  final String title;
  final String subTitle;

  const DashboardApp({
    super.key,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xff121212),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: MultiBlocProvider(
        providers: [
          // Side menu
          BlocProvider(create: (_) => SideMenuCubit()),

          // WebSocket connection
          BlocProvider(
              create: (_) => WebsocketConnectionBloc(
                    messageParser: GetIt.instance<WebSocketMessageParser>(),
                    websocket: GetIt.instance<WebSocketClient>(),
                  )),

          // Thread-related
          BlocProvider(create: (_) => ThreadActiveDatasetBloc()),
          BlocProvider(create: (_) => ThreadAddressBloc()),
          BlocProvider(create: (_) => ThreadAttachmentStatusBloc()),
          BlocProvider(create: (_) => ThreadDatasetInitFormBloc()),
          BlocProvider(create: (_) => ThreadInterfaceStatusBloc()),
          BlocProvider(create: (_) => ThreadMeshcopServiceStatusBloc()),
          BlocProvider(create: (_) => ThreadRoleBloc()),
          BlocProvider(create: (_) => ThreadStackStatusBloc()),

          // Wifi-related
          BlocProvider(
              create: (_) => WifiStaConnectBloc(
                    websocket: GetIt.instance<WebSocketClient>(),
                  )),
        ],
        child: Layout(
          title: title,
          subTitle: subTitle,
        ),
      ),
    );
  }
}
