import 'dart:convert';

import 'package:dashboard/blocs/thread/thread_role/thread_role_bloc.dart';
import 'package:dashboard/blocs/websocket_connection/websocket_connection_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/message_log/message_log_bloc.dart';
import 'blocs/thread_dataset/thread_dataset_active/thread_dataset_active_bloc.dart';
import 'blocs/thread_dataset/thread_dataset_init/thread_dataset_init_bloc.dart';
import 'pages/home_page.dart';

import 'package:get_it/get_it.dart';

class DashboardApp extends StatelessWidget {

  final getIt = GetIt.instance;

  DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard',
      home: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: getIt<ThreadDatasetInitBloc>()),
          BlocProvider.value(value: getIt<ThreadDatasetActiveBloc>()),
          BlocProvider.value(value: getIt<ThreadRoleBloc>()),
          BlocProvider.value(value: getIt<WebsocketConnectionBloc>()),
          BlocProvider.value(value: getIt<MessageLogBloc>()),
        ],
        child: const HomePage(title: "Old MacDonald"),
      ),
    );
  }
}









// import 'package:dashboard/blocs/pair_ble_thread/pair_ble_thread_bloc.dart';
// import 'package:dashboard/blocs/thread/thread_role/thread_role_bloc.dart';
// import 'package:dashboard/blocs/websocket_connection/websocket_connection_bloc.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import 'blocs/message_log/message_log_bloc.dart';
// import 'blocs/thread_dataset/thread_dataset_active/thread_dataset_active_bloc.dart';
// import 'blocs/thread_dataset/thread_dataset_init/thread_dataset_init_bloc.dart';
// import 'pages/home_page.dart';
//
// import 'package:get_it/get_it.dart';
//
// class DashboardApp extends StatelessWidget {
//
//   final getIt = GetIt.instance;
//
//   DashboardApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Dashboard',
//       home: MultiBlocProvider(
//         providers: [
//           BlocProvider.value(value: getIt<ThreadDatasetInitBloc>()),
//           BlocProvider.value(value: getIt<ThreadDatasetActiveBloc>()),
//           BlocProvider.value(value: getIt<ThreadRoleBloc>()),
//           BlocProvider.value(value: getIt<PairBleThreadBloc>()),
//           BlocProvider.value(value: getIt<WebsocketConnectionBloc>()),
//           BlocProvider.value(value: getIt<MessageLogBloc>()),
//         ],
//         child: const HomePage(title: "Old MacDonald"),
//       ),
//     );
//   }
// }