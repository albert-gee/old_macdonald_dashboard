import 'package:get_it/get_it.dart';

import 'package:dashboard/network/websocket.dart';
import 'package:dashboard/models/websocket_message.dart';
import 'blocs/thread_dataset/thread_dataset_active/thread_dataset_active_bloc.dart';
import 'blocs/thread_dataset/thread_dataset_init/thread_dataset_init_bloc.dart';
import 'blocs/websocket_connection/websocket_connection_bloc.dart';
import 'blocs/message_log/message_log_bloc.dart';
import 'blocs/cluster_command/cluster_command_bloc.dart';
import 'blocs/pair_ble_thread/pair_ble_thread_bloc.dart';
import 'blocs/read_attribute_command/read_attribute_command_bloc.dart';
import 'blocs/subscribe_attribute/subscribe_attribute_command_bloc.dart';
import 'blocs/status_card/status_card_bloc.dart';
import 'blocs/status_card/status_card_event.dart';
import 'blocs/wifi_sta_connect/wifi_sta_connect_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator(final String title, final String subTitle,
    final String wsUri, final String token) async {
  getIt.registerSingleton<String>(instanceName: 'title', title);
  getIt.registerSingleton<String>(instanceName: 'subTitle', subTitle);
  getIt.registerSingleton<String>(token);
  getIt.registerLazySingleton<Websocket>(() => Websocket(wsUri));
  getIt.registerSingleton<WebSocketMessageParser>(WebSocketMessageParser());

  _registerBlocs();
}

void _registerBlocs() {
  getIt.registerLazySingleton<StatusCardBloc<String>>(
        () => StatusCardBloc<String>('unknown'),
    instanceName: 'ifconfig',
    dispose: (bloc) => bloc.close(),
  );

  getIt.registerLazySingleton<StatusCardBloc<String>>(
        () => StatusCardBloc<String>('unknown'),
    instanceName: 'wifi_sta',
    dispose: (bloc) => bloc.close(),
  );

  getIt.registerLazySingleton<StatusCardBloc<String>>(
        () => StatusCardBloc<String>('unknown'),
    instanceName: 'thread_status',
    dispose: (bloc) => bloc.close(),
  );

  getIt.registerLazySingleton<StatusCardBloc<String>>(
        () => StatusCardBloc<String>('unknown'),
    instanceName: 'thread_role',
    dispose: (bloc) => bloc.close(),
  );

  getIt.registerLazySingleton<StatusCardBloc<String>>(
        () => StatusCardBloc<String>('0000'),
    instanceName: 'temperature',
    dispose: (bloc) => bloc.close(),
  );

  getIt.registerLazySingleton<WifiStaConnectBloc>(
        () => WifiStaConnectBloc(websocket: getIt<Websocket>()),
    dispose: (bloc) => bloc.close(),
  );

  getIt.registerLazySingleton<WebsocketConnectionBloc>(
        () => WebsocketConnectionBloc(
      websocket: getIt<Websocket>(),
      messageParser: getIt<WebSocketMessageParser>(),
      onPrintMessageToLog: (command, message) {
        getIt<MessageLogBloc>().add(MessageLogReceivedMessageEvent(command, message));
      },
      onMessageReceived: _receiveWebsocketMessage,
      onWebsocketDone: () {},
    ),
    dispose: (bloc) => bloc.close(),
  );

  getIt.registerLazySingleton<ThreadDatasetInitBloc>(
        () => ThreadDatasetInitBloc(websocket: getIt<Websocket>()),
    dispose: (bloc) => bloc.close(),
  );

  getIt.registerLazySingleton<ThreadDatasetActiveBloc>(
        () => ThreadDatasetActiveBloc(),
    dispose: (bloc) => bloc.close(),
  );

  getIt.registerLazySingleton<PairBleThreadBloc>(
        () => PairBleThreadBloc(websocket: getIt<Websocket>()),
    dispose: (bloc) => bloc.close(),
  );

  getIt.registerLazySingleton<ClusterCommandBloc>(
        () => ClusterCommandBloc(websocket: getIt<Websocket>()),
    dispose: (bloc) => bloc.close(),
  );

  getIt.registerLazySingleton<ReadAttributeCommandBloc>(
        () => ReadAttributeCommandBloc(websocket: getIt<Websocket>()),
    dispose: (bloc) => bloc.close(),
  );

  getIt.registerLazySingleton<SubscribeAttributeCommandBloc>(
        () => SubscribeAttributeCommandBloc(websocket: getIt<Websocket>()),
    dispose: (bloc) => bloc.close(),
  );

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
    case ErrorMessage:
      final msg = message as ErrorMessage;
      getIt<MessageLogBloc>().add(
        MessageLogReceivedMessageEvent('error', msg.error),
      );
      break;

    case InfoMessage:
      final msg = message as InfoMessage;
      getIt<MessageLogBloc>().add(
        MessageLogReceivedMessageEvent('info', msg.info),
      );
      break;

    case ThreadDatasetActiveMessage:
      final msg = message as ThreadDatasetActiveMessage;
      getIt<ThreadDatasetActiveBloc>().add(
        LoadThreadDataset(msg.dataset),
      );
      break;

    case ThreadRoleMessage:
      final msg = message as ThreadRoleMessage;
      getIt<StatusCardBloc<String>>(instanceName: 'thread_role')
          .add(StatusCardChanged(msg.role));
      break;

    case IfconfigStatusMessage:
      final msg = message as IfconfigStatusMessage;
      getIt<StatusCardBloc<String>>(instanceName: 'ifconfig')
          .add(StatusCardChanged(msg.status));
      break;

    case ThreadStatusMessage:
      final msg = message as ThreadStatusMessage;
      getIt<StatusCardBloc<String>>(instanceName: 'thread_status')
          .add(StatusCardChanged(msg.status));
      break;

    case WifiStaStatusMessage:
      final msg = message as WifiStaStatusMessage;
      getIt<StatusCardBloc<String>>(instanceName: 'wifi_sta')
          .add(StatusCardChanged(msg.status));
      break;

    case TemperatureSetMessage:
      final msg = message as TemperatureSetMessage;
      getIt<StatusCardBloc<String>>(instanceName: 'temperature')
          .add(StatusCardChanged(msg.temperature));
      break;

    default:
      getIt<MessageLogBloc>().add(
        MessageLogReceivedMessageEvent('info', 'Unknown message type: $message'),
      );
  }
}
