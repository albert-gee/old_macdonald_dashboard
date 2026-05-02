import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dashboard/blocs/side_menu/side_menu_cubit.dart';
import 'package:dashboard/blocs/thread/thread_active_dataset/thread_active_dataset_bloc.dart';
import 'package:dashboard/blocs/thread/thread_address/thread_address_bloc.dart';
import 'package:dashboard/blocs/thread/thread_attachment_status/thread_attachment_status_bloc.dart';
import 'package:dashboard/blocs/thread/thread_command/thread_command_bloc.dart';
import 'package:dashboard/blocs/thread/thread_dataset_form/thread_dataset_form_bloc.dart';
import 'package:dashboard/blocs/thread/thread_interface_status/thread_interface_status_bloc.dart';
import 'package:dashboard/blocs/thread/thread_meshcop_service_status/thread_meshcop_service_status_bloc.dart';
import 'package:dashboard/blocs/thread/thread_role/thread_role_bloc.dart';
import 'package:dashboard/blocs/thread/thread_stack_status/thread_stack_status_bloc.dart';
import 'package:dashboard/blocs/websocket_connection/websocket_connection_bloc.dart';
import 'package:dashboard/blocs/wifi_sta_connect/wifi_sta_connection_bloc.dart';
import 'package:dashboard/src/core/config/app_config.dart';
import 'package:dashboard/src/core/config/app_dependencies.dart';
import 'package:dashboard/src/core/theme/app_theme.dart';
import 'package:dashboard/websocket/websocket_inbound_message_handler.dart';

import 'layout.dart';

class DashboardApp extends StatefulWidget {
  final AppConfig config;
  final AppDependencies dependencies;

  const DashboardApp({
    super.key,
    required this.config,
    required this.dependencies,
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
  late final ThreadCommandBloc _threadCommandBloc;
  late final ThreadDatasetInitFormBloc _threadDatasetInitFormBloc;
  late final ThreadInterfaceStatusBloc _threadInterfaceStatusBloc;
  late final ThreadMeshcopServiceStatusBloc _threadMeshcopServiceStatusBloc;
  late final ThreadRoleBloc _threadRoleBloc;
  late final ThreadStackStatusBloc _threadStackStatusBloc;
  late final WifiStaConnectionBloc _wifiStaConnectionBloc;

  @override
  void initState() {
    super.initState();

    _sideMenuCubit = SideMenuCubit();
    _threadActiveDatasetBloc = ThreadActiveDatasetBloc();
    _threadAddressBloc = ThreadAddressBloc();
    _threadAttachmentStatusBloc = ThreadAttachmentStatusBloc();
    _threadCommandBloc = ThreadCommandBloc(
      threadCommandService: widget.dependencies.threadCommandService,
    );
    _threadDatasetInitFormBloc = ThreadDatasetInitFormBloc(
      threadCommandService: widget.dependencies.threadCommandService,
    );
    _threadInterfaceStatusBloc = ThreadInterfaceStatusBloc();
    _threadMeshcopServiceStatusBloc = ThreadMeshcopServiceStatusBloc();
    _threadRoleBloc = ThreadRoleBloc();
    _threadStackStatusBloc = ThreadStackStatusBloc();
    _wifiStaConnectionBloc = WifiStaConnectionBloc(
      wifiCommandService: widget.dependencies.wifiCommandService,
    );

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
      websocket: widget.dependencies.webSocketClient,
      messageHandler: messageHandler,
      urlStorage: widget.dependencies.orchestratorUrlStorage,
    );
  }

  @override
  void dispose() {
    _sideMenuCubit.close();
    _websocketConnectionBloc.close();
    _threadActiveDatasetBloc.close();
    _threadAddressBloc.close();
    _threadAttachmentStatusBloc.close();
    _threadCommandBloc.close();
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
      title: widget.config.appTitle,
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
          BlocProvider.value(value: _threadCommandBloc),
          BlocProvider.value(value: _threadDatasetInitFormBloc),
          BlocProvider.value(value: _threadInterfaceStatusBloc),
          BlocProvider.value(value: _threadMeshcopServiceStatusBloc),
          BlocProvider.value(value: _threadRoleBloc),
          BlocProvider.value(value: _threadStackStatusBloc),

          // Wi-Fi actions
          BlocProvider.value(value: _wifiStaConnectionBloc),
        ],
        child: Layout(
          title: widget.config.appTitle,
          subTitle: widget.config.appSubtitle,
          orchestratorUrlStorage: widget.dependencies.orchestratorUrlStorage,
        ),
      ),
    );
  }
}
