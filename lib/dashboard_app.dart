import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'blocs/side_menu/side_menu_cubit.dart';
import 'layout.dart';
import 'network/websocket.dart';
import 'models/websocket_message.dart';

import 'blocs/thread/thread_active_dataset/thread_active_dataset_bloc.dart';
import 'blocs/thread/thread_address/thread_address_bloc.dart';
import 'blocs/thread/thread_attachment_status/thread_attachment_status_bloc.dart';
import 'blocs/thread/thread_dataset_init_form/thread_dataset_init_form_bloc.dart';
import 'blocs/thread/thread_interface_status/thread_interface_status_bloc.dart';
import 'blocs/thread/thread_meshcop_service_status/thread_meshcop_service_status_bloc.dart';
import 'blocs/thread/thread_role/thread_role_bloc.dart';
import 'blocs/thread/thread_stack_status/thread_stack_status_bloc.dart';
import 'blocs/message_log/message_log_bloc.dart';
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
          BlocProvider(create: (_) =>
              WifiStaConnectBloc(
                websocket: GetIt.instance<Websocket>(),
              )),

          // Message log
          BlocProvider(create: (_) =>
              MessageLogBloc(
                onMessageReceived: (message) {},
                onMessageSent: (command, payload) {},
              )),

          // WebSocket
          BlocProvider(create: (_) =>
              WebsocketConnectionBloc(
                messageParser: GetIt.instance<WebSocketMessageParser>(),
                websocket: GetIt.instance<Websocket>(),
                onPrintMessageToLog: (cmd, msg) {},
                onMessageReceived: _receiveWebsocketMessage,
                onWebsocketDone: () {},
              )),

          // Side menu logic
          BlocProvider(create: (_) => SideMenuCubit()),
        ],
        child: Layout(
          title: title,
          subTitle: subTitle,
        ),
      ),
    );
  }

  void _receiveWebsocketMessage(WebSocketMessage message) {
    print('_receiveWebsocketMessage: $message');
  }

}


// switch (message.runtimeType) {
    //   case ErrorMessage:
    //     final msg = message as ErrorMessage;
    //     getIt<MessageLogBloc>().add(
    //       MessageLogReceivedMessageEvent('error', msg.error),
    //     );
    //     break;
    //
    //   case InfoMessage:
    //     final msg = message as InfoMessage;
    //     getIt<MessageLogBloc>().add(
    //       MessageLogReceivedMessageEvent('info', msg.info),
    //     );
    //     break;
    //
    //   case ThreadDatasetActiveMessage:
    //     final msg = message as ThreadDatasetActiveMessage;
    //     getIt<ThreadDatasetActiveBloc>().add(
    //       LoadThreadDataset(msg.dataset),
    //     );
    //     break;
    //
    //   case ThreadRoleMessage:
    //     final msg = message as ThreadRoleMessage;
    //     getIt<StatusCardBloc<String>>(instanceName: 'thread_role')
    //         .add(StatusCardChanged(msg.role));
    //     break;
    //
    //   case IfconfigStatusMessage:
    //     final msg = message as IfconfigStatusMessage;
    //     getIt<StatusCardBloc<String>>(instanceName: 'ifconfig')
    //         .add(StatusCardChanged(msg.status));
    //     break;
    //
    //   case ThreadStatusMessage:
    //     final msg = message as ThreadStatusMessage;
    //     getIt<StatusCardBloc<String>>(instanceName: 'thread_status')
    //         .add(StatusCardChanged(msg.status));
    //     break;
    //
    //   case WifiStaStatusMessage:
    //     final msg = message as WifiStaStatusMessage;
    //     getIt<StatusCardBloc<String>>(instanceName: 'wifi_sta')
    //         .add(StatusCardChanged(msg.status));
    //     break;
    //
    //   case TemperatureSetMessage:
    //     final msg = message as TemperatureSetMessage;
    //     getIt<StatusCardBloc<String>>(instanceName: 'temperature')
    //         .add(StatusCardChanged(msg.temperature));
    //     break;
    //
    //   default:
    //     getIt<MessageLogBloc>().add(
    //       MessageLogReceivedMessageEvent('info', 'Unknown message type: $message'),
    //     );
    // }
//   }
// }
