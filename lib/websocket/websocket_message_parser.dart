import 'dart:convert';

import 'package:dashboard/websocket/websocket_message.dart';

/// Parser for converting raw WebSocket messages to typed objects
class WebSocketMessageParser {

  WebSocketMessage parse(String message) {
    print("WebSocketMessageParser: parse: message: $message");
    try {
      final json = jsonDecode(message);

      if (json is! Map<String, dynamic>) {
        throw MessageParseException('Expected JSON object');
      }

      // Special-case messages like:
      // {"type":"websocket","payload":{"connected":true}}
      if (!json.containsKey('command') && json['type'] == 'websocket') {
        return GenericMessage(command: 'websocket', payload: json['payload']);
      }

      return WebSocketMessage.fromJson(json);
    } on FormatException catch (e) {
      throw MessageParseException('Invalid JSON format: $e');
    } on TypeError catch (e) {
      throw MessageParseException('Invalid message structure: $e');
    } catch (e) {
      throw MessageParseException('Unexpected error: $e');
    }
  }
}

/// Exception thrown when message parsing fails
class MessageParseException implements Exception {
  final String message;
  const MessageParseException(this.message);

  @override
  String toString() => 'MessageParseException: $message';
}


void _receiveWebsocketMessage(WebSocketMessage message) {
  print('_receiveWebsocketMessage: $message');

  // switch (message.runtimeType) {
  //   case ErrorMessage:
  //     final msg = message as ErrorMessage;
  //     GetIt.instance<MessageLogBloc>().add(
  //       MessageLogReceivedMessageEvent('error', msg.error),
  //     );
  //     break;
  //
  //   case InfoMessage:
  //     final msg = message as InfoMessage;
  //     GetIt.instance<MessageLogBloc>().add(
  //       MessageLogReceivedMessageEvent('info', msg.info),
  //     );
  //     break;
  //
  //   case ThreadDatasetActiveMessage:
  //     final msg = message as ThreadDatasetActiveMessage;
  //     GetIt.instance<ThreadDatasetActiveBloc>().add(
  //       LoadThreadDataset(msg.dataset),
  //     );
  //     break;
  //
  //   case ThreadRoleMessage:
  //     final msg = message as ThreadRoleMessage;
  //     GetIt.instance<StatusCardBloc<String>>(instanceName: 'thread_role')
  //         .add(StatusCardChanged(msg.role));
  //     break;
  //
  //   case IfconfigStatusMessage:
  //     final msg = message as IfconfigStatusMessage;
  //     GetIt.instance<StatusCardBloc<String>>(instanceName: 'ifconfig')
  //         .add(StatusCardChanged(msg.status));
  //     break;
  //
  //   case ThreadStatusMessage:
  //     final msg = message as ThreadStatusMessage;
  //     GetIt.instance<StatusCardBloc<String>>(instanceName: 'thread_status')
  //         .add(StatusCardChanged(msg.status));
  //     break;
  //
  //   case WifiStaStatusMessage:
  //     final msg = message as WifiStaStatusMessage;
  //     GetIt.instance<StatusCardBloc<String>>(instanceName: 'wifi_sta')
  //         .add(StatusCardChanged(msg.status));
  //     break;
  //
  //   case TemperatureSetMessage:
  //     final msg = message as TemperatureSetMessage;
  //     GetIt.instance<StatusCardBloc<String>>(instanceName: 'temperature')
  //         .add(StatusCardChanged(msg.temperature));
  //     break;
  //
  //   default:
  //     GetIt.instance<MessageLogBloc>().add(
  //       MessageLogReceivedMessageEvent('info', 'Unknown message type: $message'),
  //     );
  // }
}