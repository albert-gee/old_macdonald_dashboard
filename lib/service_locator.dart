import 'package:dashboard/blocs/thread_dataset/thread_dataset_active/thread_dataset_active_bloc.dart';
import 'package:dashboard/blocs/thread_dataset/thread_dataset_init/thread_dataset_init_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:dashboard/network/websocket.dart';
import 'package:dashboard/blocs/websocket_connection/websocket_connection_bloc.dart';
import 'package:dashboard/blocs/message_log/message_log_bloc.dart';
import 'package:dashboard/models/websocket_message.dart';

import 'blocs/thread/thread_role/thread_role_bloc.dart';

final getIt = GetIt.instance;

String token = "";

Future<void> setupServiceLocator(
    final String wsUri, final String newToken) async {
  token = newToken;

  // Register WebSocket client
  _registerWebSocket(wsUri);

  // Register message parser
  _registerMessageParser();

  // Register BLoCs
  _registerBlocs();
}

void _registerWebSocket(final String wsUri) {
  getIt.registerLazySingleton<Websocket>(() => Websocket(wsUri));
}

void _registerMessageParser() {
  getIt.registerSingleton<WebSocketMessageParser>(
    WebSocketMessageParser(),
  );
}

void _registerBlocs() {
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

  // Message Log BLoC
  getIt.registerLazySingleton<MessageLogBloc>(
    () => MessageLogBloc(
      onMessageReceived: (message) {},
      onMessageSent: (command, payload) => _sendWebSocketMessage({
        'token': token,
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

    default:
      getIt<MessageLogBloc>().add(
        MessageLogReceivedMessageEvent(
            'info', 'Unknown message type: $message'),
      );
  }
}



// import 'package:dashboard/blocs/pair_ble_thread/pair_ble_thread_bloc.dart';
// import 'package:dashboard/blocs/thread_dataset/thread_dataset_active/thread_dataset_active_bloc.dart';
// import 'package:dashboard/blocs/thread_dataset/thread_dataset_init/thread_dataset_init_bloc.dart';
// import 'package:get_it/get_it.dart';
// import 'package:dashboard/network/websocket.dart';
// import 'package:dashboard/blocs/websocket_connection/websocket_connection_bloc.dart';
// import 'package:dashboard/blocs/message_log/message_log_bloc.dart';
// import 'package:dashboard/models/websocket_message.dart';
//
// import 'blocs/thread/thread_role/thread_role_bloc.dart';
//
// final getIt = GetIt.instance;
//
// String token = "";
//
// Future<void> setupServiceLocator(
//     final String wsUri, final String newToken) async {
//   token = newToken;
//
//   // Register WebSocket client
//   _registerWebSocket(wsUri);
//
//   // Register message parser
//   _registerMessageParser();
//
//   // Register BLoCs
//   _registerBlocs();
// }
//
// void _registerWebSocket(final String wsUri) {
//   getIt.registerLazySingleton<Websocket>(() => Websocket(wsUri));
// }
//
// void _registerMessageParser() {
//   getIt.registerSingleton<WebSocketMessageParser>(
//     WebSocketMessageParser(),
//   );
// }
//
// void _registerBlocs() {
//   // Websocket Connection Bloc
//   getIt.registerLazySingleton<WebsocketConnectionBloc>(
//         () => WebsocketConnectionBloc(
//       websocket: getIt<Websocket>(),
//       messageParser: getIt<WebSocketMessageParser>(),
//       onPrintMessageToLog: (command, message) {
//         getIt<MessageLogBloc>()
//             .add(MessageLogReceivedMessageEvent(command, message));
//       },
//       onMessageReceived: _receiveWebsocketMessage,
//       onWebsocketDone: () {},
//     ),
//     dispose: (bloc) => bloc.close(),
//   );
//
//   // Thread Dataset Init BLoC
//   getIt.registerLazySingleton<ThreadDatasetInitBloc>(
//         () => ThreadDatasetInitBloc(websocket: getIt<Websocket>()),
//     dispose: (bloc) => bloc.close(),
//   );
//
//   // Thread Dataset Active BLoC
//   getIt.registerLazySingleton<ThreadDatasetActiveBloc>(
//         () => ThreadDatasetActiveBloc(),
//     dispose: (bloc) => bloc.close(),
//   );
//
//   // Thread Role Bloc
//   getIt.registerLazySingleton<ThreadRoleBloc>(
//         () => ThreadRoleBloc(),
//     dispose: (bloc) => bloc.close(),
//   );
//
//   // Pair BLE Thread BLoC
//   getIt.registerLazySingleton<PairBleThreadBloc>(
//         () => PairBleThreadBloc(websocket: getIt<Websocket>()),
//     dispose: (bloc) => bloc.close(),
//   );
//
//   // Message Log BLoC
//   getIt.registerLazySingleton<MessageLogBloc>(
//         () => MessageLogBloc(
//       onMessageReceived: (message) {},
//       onMessageSent: (command, payload) => _sendWebSocketMessage({
//         'token': token,
//         'command': command,
//         'payload': payload,
//       }),
//     ),
//     dispose: (bloc) => bloc.close(),
//   );
//
// }
//
// Future<bool> _sendWebSocketMessage(Map<String, dynamic> message) async {
//   print('_sendWebSocketMessage: $message');
//
//   try {
//     return await getIt<Websocket>().sendJsonMessage(message);
//   } catch (e) {
//     getIt<MessageLogBloc>().add(
//       MessageLogReceivedMessageEvent('error', 'Failed to send message: $e'),
//     );
//     return false;
//   }
// }
//
// void _receiveWebsocketMessage(WebSocketMessage message) {
//   print('_receiveWebsocketMessage: $message');
//
//   switch (message.runtimeType) {
//   // Error Message
//     case ErrorMessage:
//       final msg = message as ErrorMessage;
//       getIt<MessageLogBloc>().add(
//         MessageLogReceivedMessageEvent('error', msg.error),
//       );
//       break;
//
//   // InfoMessage
//     case InfoMessage:
//       final msg = message as InfoMessage;
//       getIt<MessageLogBloc>().add(
//         MessageLogReceivedMessageEvent('info', msg.info),
//       );
//       break;
//
//   // Thread Dataset Active Message
//     case ThreadDatasetActiveMessage:
//       final msg = message as ThreadDatasetActiveMessage;
//       getIt<ThreadDatasetActiveBloc>().add(
//         LoadThreadDataset(msg.dataset),
//       );
//       break;
//
//   // Thread Role Message
//     case ThreadRoleMessage:
//       final msg = message as ThreadRoleMessage;
//       getIt<ThreadRoleBloc>().add(ThreadRoleChanged(msg.role));
//       break;
//
//     case PairingBleThreadStartMessage:
//       final msg = message as PairingBleThreadStartMessage;
//       getIt<MessageLogBloc>().add(
//         MessageLogReceivedMessageEvent('pairing', 'Starting BLE Thread pairing for node ${msg.nodeId}'),
//       );
//       break;
//
//     case PairingBleThreadProgressMessage:
//       final msg = message as PairingBleThreadProgressMessage;
//       getIt<MessageLogBloc>().add(
//         MessageLogReceivedMessageEvent('pairing', '${msg.message} (${(msg.progress * 100).toStringAsFixed(0)}%)'),
//       );
//       break;
//
//     case PairingBleThreadCompleteMessage:
//       final msg = message as PairingBleThreadCompleteMessage;
//       getIt<MessageLogBloc>().add(
//         MessageLogReceivedMessageEvent('pairing', 'Pairing complete: ${msg.result}'),
//       );
//       break;
//
//     case PairingBleThreadErrorMessage:
//       final msg = message as PairingBleThreadErrorMessage;
//       getIt<MessageLogBloc>().add(
//         MessageLogReceivedMessageEvent('pairing-error', 'Pairing failed: ${msg.error}'),
//       );
//       break;
//
//     default:
//       getIt<MessageLogBloc>().add(
//         MessageLogReceivedMessageEvent(
//             'info', 'Unknown message type: $message'),
//       );
//   }
// }
