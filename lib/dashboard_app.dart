import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'services/i_orchestrator_url_storage.dart';
import 'styles/app_theme.dart';
import 'layout.dart';
import 'websocket/websocket_client.dart';
import 'websocket/websocket_inbound_message_handler.dart';

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

class DashboardApp extends StatefulWidget {
  final String title;
  final String subTitle;

  const DashboardApp({
    super.key,
    required this.title,
    required this.subTitle,
  });

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  late final SideMenuCubit _sideMenuCubit;
  late final WebsocketConnectionBloc _websocketConnectionBloc;
  late final ThreadActiveDatasetBloc _threadActiveDatasetBloc;
  late final ThreadAddressBloc _threadAddressBloc;
  late final ThreadAttachmentStatusBloc _threadAttachmentStatusBloc;
  late final ThreadDatasetInitFormBloc _threadDatasetInitFormBloc;
  late final ThreadInterfaceStatusBloc _threadInterfaceStatusBloc;
  late final ThreadMeshcopServiceStatusBloc _threadMeshcopServiceStatusBloc;
  late final ThreadRoleBloc _threadRoleBloc;
  late final ThreadStackStatusBloc _threadStackStatusBloc;
  late final WifiStaConnectionBloc _wifiStaConnectionBloc;

  @override
  void initState() {
    super.initState();
    final getIt = GetIt.instance;

    _sideMenuCubit = SideMenuCubit();
    _threadActiveDatasetBloc = ThreadActiveDatasetBloc();
    _threadAddressBloc = ThreadAddressBloc();
    _threadAttachmentStatusBloc = ThreadAttachmentStatusBloc();
    _threadDatasetInitFormBloc = ThreadDatasetInitFormBloc();
    _threadInterfaceStatusBloc = ThreadInterfaceStatusBloc();
    _threadMeshcopServiceStatusBloc = ThreadMeshcopServiceStatusBloc();
    _threadRoleBloc = ThreadRoleBloc();
    _threadStackStatusBloc = ThreadStackStatusBloc();
    _wifiStaConnectionBloc = WifiStaConnectionBloc();

    final messageHandler = WebSocketInboundMessageHandler(
      threadStackStatusBloc: _threadStackStatusBloc,
      threadInterfaceStatusBloc: _threadInterfaceStatusBloc,
      threadAttachmentStatusBloc: _threadAttachmentStatusBloc,
      threadRoleBloc: _threadRoleBloc,
      threadActiveDatasetBloc: _threadActiveDatasetBloc,
      threadAddressBloc: _threadAddressBloc,
      threadMeshcopServiceStatusBloc: _threadMeshcopServiceStatusBloc,
    );

    _websocketConnectionBloc = WebsocketConnectionBloc(
      websocket: getIt<WebSocketClient>(),
      messageHandler: messageHandler,
      urlStorage: getIt<IOrchestratorUrlStorage>(),
    );
  }

  @override
  void dispose() {
    _sideMenuCubit.close();
    _websocketConnectionBloc.close();
    _threadActiveDatasetBloc.close();
    _threadAddressBloc.close();
    _threadAttachmentStatusBloc.close();
    _threadDatasetInitFormBloc.close();
    _threadInterfaceStatusBloc.close();
    _threadMeshcopServiceStatusBloc.close();
    _threadRoleBloc.close();
    _threadStackStatusBloc.close();
    _wifiStaConnectionBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: widget.title,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: MultiBlocProvider(
        providers: [
          // UI State
          BlocProvider.value(value: _sideMenuCubit),

          // WebSocket
          BlocProvider.value(value: _websocketConnectionBloc),

          // Thread indicators
          BlocProvider.value(value: _threadActiveDatasetBloc),
          BlocProvider.value(value: _threadAddressBloc),
          BlocProvider.value(value: _threadAttachmentStatusBloc),
          BlocProvider.value(value: _threadDatasetInitFormBloc),
          BlocProvider.value(value: _threadInterfaceStatusBloc),
          BlocProvider.value(value: _threadMeshcopServiceStatusBloc),
          BlocProvider.value(value: _threadRoleBloc),
          BlocProvider.value(value: _threadStackStatusBloc),

          // Wi-Fi actions
          BlocProvider.value(value: _wifiStaConnectionBloc),
        ],
        child: Layout(
          title: widget.title,
          subTitle: widget.subTitle,
        ),
      ),
    );
  }
}
