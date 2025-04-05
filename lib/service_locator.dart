import 'package:dashboard/blocs/thread_dataset/thread_dataset_active/thread_dataset_active_bloc.dart';
import 'package:dashboard/blocs/thread_dataset/thread_dataset_init/thread_dataset_init_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:dashboard/network/websocket.dart';
import 'package:dashboard/blocs/websocket_connection/websocket_connection_bloc.dart';
import 'package:dashboard/blocs/message_log/message_log_bloc.dart';
import 'package:dashboard/models/websocket_message.dart';

import 'blocs/cluster_command/cluster_command_bloc.dart';
import 'blocs/pair_ble_thread/pair_ble_thread_bloc.dart';
import 'blocs/read_attribute_command/read_attribute_command_bloc.dart';
import 'blocs/subscribe_attribute/subscribe_attribute_command_bloc.dart';
import 'blocs/thread/ifconfig_status/ifconfig_status_bloc.dart';
import 'blocs/thread/thread_role/thread_role_bloc.dart';
import 'blocs/thread/thread_status/thread_status_bloc.dart';
import 'blocs/wifi_sta_connect/wifi_sta_connect_bloc.dart';
import 'blocs/wifi_sta_status/wifi_sta_status_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator(final String title, final String subTitle,
    final String wsUri, final String token) async {
  // Register title and subtitle
  getIt.registerSingleton<String>(instanceName: 'title', title);
  getIt.registerSingleton<String>(instanceName: 'subTitle', subTitle);

  // Register token
  getIt.registerSingleton<String>(token);

  // Register WebSocket client
  getIt.registerLazySingleton<Websocket>(() => Websocket(wsUri));

  // Register message parser
  getIt.registerSingleton<WebSocketMessageParser>(WebSocketMessageParser());

  // Register BLoCs
  _registerBlocs();
}

void _registerBlocs() {
  // WiFi STA Connect BLoC
  getIt.registerLazySingleton<WifiStaConnectBloc>(
    () => WifiStaConnectBloc(
      websocket: getIt<Websocket>(),
    ),
    dispose: (bloc) => bloc.close(),
  );

  // Websocket Connection Bloc
  getIt.registerLazySingleton<WebsocketConnectionBloc>(
    () => WebsocketConnectionBloc(
      websocket: getIt<Websocket>(),
      messageParser: getIt<WebSocketMessageParser>(),
      onPrintMessageToLog: (command, message) {
        getIt<MessageLogBloc>()
            .add(MessageLogReceivedMessageEvent(command, message));
      },
      onMessageReceived: _receiveWebsocketMessage,
      onWebsocketDone: () {},
    ),
    dispose: (bloc) => bloc.close(),
  );

  // Ifconfig Status Bloc
  getIt.registerLazySingleton<IfconfigStatusBloc>(
        () => IfconfigStatusBloc(),
    dispose: (bloc) => bloc.close(),
  );

  // Wifi Sta Status Bloc
  getIt.registerLazySingleton<WifiStaStatusBloc>(
        () => WifiStaStatusBloc(),
    dispose: (bloc) => bloc.close(),
  );

  // Thread Status Bloc
  getIt.registerLazySingleton<ThreadStatusBloc>(
        () => ThreadStatusBloc(),
    dispose: (bloc) => bloc.close(),
  );

  // Thread Dataset Init BLoC
  getIt.registerLazySingleton<ThreadDatasetInitBloc>(
    () => ThreadDatasetInitBloc(websocket: getIt<Websocket>()),
    dispose: (bloc) => bloc.close(),
  );

  // Thread Dataset Active BLoC
  getIt.registerLazySingleton<ThreadDatasetActiveBloc>(
    () => ThreadDatasetActiveBloc(),
    dispose: (bloc) => bloc.close(),
  );

  // Thread Role Bloc
  getIt.registerLazySingleton<ThreadRoleBloc>(
    () => ThreadRoleBloc(),
    dispose: (bloc) => bloc.close(),
  );

  // Pair Ble-Thread Bloc
  getIt.registerLazySingleton<PairBleThreadBloc>(
    () => PairBleThreadBloc(
      websocket: getIt<Websocket>(),
    ),
    dispose: (bloc) => bloc.close(),
  );
  // Cluster Command Bloc
  getIt.registerLazySingleton<ClusterCommandBloc>(
    () => ClusterCommandBloc(
      websocket: getIt<Websocket>(),
    ),
    dispose: (bloc) => bloc.close(),
  );
  // Read Attribute Command Bloc
  getIt.registerLazySingleton<ReadAttributeCommandBloc>(
    () => ReadAttributeCommandBloc(
      websocket: getIt<Websocket>(),
    ),
    dispose: (bloc) => bloc.close(),
  );
  // Subscribe Attribute Command Bloc
  getIt.registerLazySingleton<SubscribeAttributeCommandBloc>(
    () => SubscribeAttributeCommandBloc(
      websocket: getIt<Websocket>(),
    ),
    dispose: (bloc) => bloc.close(),
  );

  // Message Log BLoC
  getIt.registerLazySingleton<MessageLogBloc>(
    () => MessageLogBloc(
      onMessageReceived: (message) {},
      onMessageSent: (command, payload) => _sendWebSocketMessage({
        'command': command,
        'payload': payload,
      }),
    ),
    dispose: (bloc) => bloc.close(),
  );
}

Future<bool> _sendWebSocketMessage(Map<String, dynamic> message) async {
  print('_sendWebSocketMessage: $message');

  try {
    return await getIt<Websocket>().sendJsonMessage(message);
  } catch (e) {
    getIt<MessageLogBloc>().add(
      MessageLogReceivedMessageEvent('error', 'Failed to send message: $e'),
    );
    return false;
  }
}

void _receiveWebsocketMessage(WebSocketMessage message) {
  print('_receiveWebsocketMessage: $message');

  switch (message.runtimeType) {
    // Error Message
    case ErrorMessage:
      final msg = message as ErrorMessage;
      getIt<MessageLogBloc>().add(
        MessageLogReceivedMessageEvent('error', msg.error),
      );
      break;

    // InfoMessage
    case InfoMessage:
      final msg = message as InfoMessage;
      getIt<MessageLogBloc>().add(
        MessageLogReceivedMessageEvent('info', msg.info),
      );
      break;

    // Thread Dataset Active Message
    case ThreadDatasetActiveMessage:
      final msg = message as ThreadDatasetActiveMessage;
      getIt<ThreadDatasetActiveBloc>().add(
        LoadThreadDataset(msg.dataset),
      );
      break;

    // Thread Role Message
    case ThreadRoleMessage:
      final msg = message as ThreadRoleMessage;
      getIt<ThreadRoleBloc>().add(ThreadRoleChanged(msg.role));
      break;

    // Ifconfig Status Message
    case IfconfigStatusMessage:
      final msg = message as IfconfigStatusMessage;
      getIt<IfconfigStatusBloc>().add(IfconfigStatusChanged(msg.status));
      break;

    // Thread Status Message
    case ThreadStatusMessage:
      final msg = message as ThreadStatusMessage;
      getIt<ThreadStatusBloc>().add(ThreadStatusChanged(msg.status));
      break;

    // Thread Status Message
    case WifiStaStatusMessage:
      final msg = message as WifiStaStatusMessage;
      getIt<WifiStaStatusBloc>().add(WifiStaStatusChanged(msg.status));
      break;

    default:
      getIt<MessageLogBloc>().add(
        MessageLogReceivedMessageEvent(
            'info', 'Unknown message type: $message'),
      );
  }
}
