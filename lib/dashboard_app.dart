import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'styles/app_theme.dart';
import 'layout.dart';
import 'websocket/websocket_client.dart';
import 'websocket/websocket_message_handler.dart';

// BLoCs
import 'blocs/side_menu/side_menu_cubit.dart';
import 'blocs/websocket_connection/websocket_connection_bloc.dart';
import 'blocs/wifi_sta_connect/wifi_sta_connection_bloc.dart';

import 'blocs/thread/thread_active_dataset/thread_active_dataset_bloc.dart';
import 'blocs/thread/thread_address/thread_address_bloc.dart';
import 'blocs/thread/thread_attachment_status/thread_attachment_status_bloc.dart';
import 'blocs/thread/thread_dataset_init_form/thread_dataset_init_form_bloc.dart';
import 'blocs/thread/thread_interface_status/thread_interface_status_bloc.dart';
import 'blocs/thread/thread_meshcop_service_status/thread_meshcop_service_status_bloc.dart';
import 'blocs/thread/thread_role/thread_role_bloc.dart';
import 'blocs/thread/thread_stack_status/thread_stack_status_bloc.dart';

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
    final getIt = GetIt.instance;

    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: MultiBlocProvider(
        providers: [
          // UI State
          BlocProvider(create: (_) => SideMenuCubit()),

          // WebSocket
          BlocProvider(
            create: (_) => WebsocketConnectionBloc(
              websocket: getIt<WebSocketClient>(),
              messageHandler: getIt<WebSocketMessageHandler>(),
            ),
          ),

          // Thread indicators
          BlocProvider(create: (_) => ThreadActiveDatasetBloc()),
          BlocProvider(create: (_) => ThreadAddressBloc()),
          BlocProvider(create: (_) => ThreadAttachmentStatusBloc()),
          BlocProvider(create: (_) => ThreadDatasetInitFormBloc()),
          BlocProvider(create: (_) => ThreadInterfaceStatusBloc()),
          BlocProvider(create: (_) => ThreadMeshcopServiceStatusBloc()),
          BlocProvider(create: (_) => ThreadRoleBloc()),
          BlocProvider(create: (_) => ThreadStackStatusBloc()),

          // Wi-Fi actions
          BlocProvider(create: (_) => WifiStaConnectionBloc()),
        ],
        child: Layout(
          title: title,
          subTitle: subTitle,
        ),
      ),
    );
  }
}
