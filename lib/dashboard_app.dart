import 'dart:convert';

import 'package:dashboard/blocs/thread/thread_role/thread_role_bloc.dart';
import 'package:dashboard/blocs/websocket_connection/websocket_connection_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/cluster_command/cluster_command_bloc.dart';
import 'blocs/message_log/message_log_bloc.dart';
import 'blocs/pair_ble_thread/pair_ble_thread_bloc.dart';
import 'blocs/read_attribute_command/read_attribute_command_bloc.dart';
import 'blocs/subscribe_attribute/subscribe_attribute_command_bloc.dart';
import 'blocs/temperature_set/temperature_set_bloc.dart';
import 'blocs/thread/ifconfig_status/ifconfig_status_bloc.dart';
import 'blocs/thread/thread_status/thread_status_bloc.dart';
import 'blocs/thread_dataset/thread_dataset_active/thread_dataset_active_bloc.dart';
import 'blocs/thread_dataset/thread_dataset_init/thread_dataset_init_bloc.dart';
import 'blocs/wifi_sta_connect/wifi_sta_connect_bloc.dart';
import 'blocs/wifi_sta_status/wifi_sta_status_bloc.dart';
import 'pages/home_page.dart';

import 'package:get_it/get_it.dart';

class DashboardApp extends StatelessWidget {

  final GetIt getIt = GetIt.instance;

  DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: getIt<String>(instanceName: 'title'),
      home: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: getIt<WebsocketConnectionBloc>()),
          BlocProvider.value(value: getIt<IfconfigStatusBloc>()),
          BlocProvider.value(value: getIt<ThreadStatusBloc>()),
          BlocProvider.value(value: getIt<WifiStaStatusBloc>()),
          BlocProvider.value(value: getIt<ThreadRoleBloc>()),
          BlocProvider.value(value: getIt<WifiStaConnectBloc>()),
          BlocProvider.value(value: getIt<ThreadDatasetInitBloc>()),
          BlocProvider.value(value: getIt<ThreadDatasetActiveBloc>()),
          BlocProvider.value(value: getIt<PairBleThreadBloc>()),
          BlocProvider.value(value: getIt<ClusterCommandBloc>()),
          BlocProvider.value(value: getIt<ReadAttributeCommandBloc>()),
          BlocProvider.value(value: getIt<SubscribeAttributeCommandBloc>()),
          BlocProvider.value(value: getIt<MessageLogBloc>()),
          BlocProvider.value(value: getIt<TemperatureSetBloc>()),
        ],
        child: HomePage(
            title: getIt<String>(instanceName: 'title'),
            subTitle: getIt<String>(instanceName: 'subTitle')),
      ),
    );
  }
}
