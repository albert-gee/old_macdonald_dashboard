import 'dart:convert';
import 'package:dashboard/blocs/thread/thread_active_dataset/thread_active_dataset_bloc.dart';
import 'package:dashboard/blocs/thread/thread_active_dataset/thread_active_dataset_event.dart';
import 'package:dashboard/blocs/thread/thread_attachment_status/thread_attachment_status_bloc.dart';
import 'package:dashboard/blocs/thread/thread_attachment_status/thread_attachment_status_event.dart';
import 'package:dashboard/blocs/thread/thread_interface_status/thread_interface_status_bloc.dart';
import 'package:dashboard/blocs/thread/thread_interface_status/thread_interface_status_event.dart';
import 'package:dashboard/blocs/thread/thread_role/thread_role_bloc.dart';
import 'package:dashboard/blocs/thread/thread_role/thread_role_event.dart';
import 'package:dashboard/blocs/thread/thread_stack_status/thread_stack_status_bloc.dart';
import 'package:dashboard/blocs/thread/thread_stack_status/thread_stack_status_event.dart';
import 'package:dashboard/blocs/websocket_connection/websocket_connection_bloc.dart';
import 'package:dashboard/websocket/websocket_message.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class WebSocketMessageHandler {

  final Logger _logger = Logger();

  void handle(String rawMessage) {
    try {
      final decoded = jsonDecode(rawMessage);
      if (decoded is! Map<String, dynamic>) {
        throw MessageParseException('Expected JSON object');
      }

      final msg = WebSocketMessage.fromJson(decoded);
      _dispatchMessage(msg);
    } catch (e) {
      _logger.e('Failed to parse WebSocket message', error: e);
    }
  }

  void _dispatchMessage(WebSocketMessage msg) {
    switch (msg.runtimeType) {
      case WebSocketConnectedMessage _:
        GetIt.I<WebsocketConnectionBloc>().add(
          WebsocketConnectionConnected(),
        );
        break;

      case ThreadStackStatusMessage _:
        final m = msg as ThreadStackStatusMessage;
        GetIt.I<ThreadStackStatusBloc>().add(
          ThreadStackStatusUpdated(m.running),
        );
        break;

      case ThreadInterfaceStatusMessage _:
        final m = msg as ThreadInterfaceStatusMessage;
        GetIt.I<ThreadInterfaceStatusBloc>().add(
          ThreadInterfaceStatusUpdated(m.interfaceUp),
        );
        break;

      case ThreadAttachmentStatusMessage _:
        final m = msg as ThreadAttachmentStatusMessage;
        GetIt.I<ThreadAttachmentStatusBloc>().add(
          ThreadAttachmentStatusUpdated(m.attached),
        );
        break;

      case ThreadRoleMessage _:
        final m = msg as ThreadRoleMessage;
        GetIt.I<ThreadRoleBloc>().add(
          ThreadRoleUpdated(m.role),
        );
        break;

      case ThreadDatasetActiveMessage _:
        final m = msg as ThreadDatasetActiveMessage;
        GetIt.I<ThreadActiveDatasetBloc>().add(ThreadActiveDatasetUpdated(
          activeTimestamp: m.dataset['active_timestamp'] ?? 0,
          networkName: m.dataset['network_name'] ?? '',
          extendedPanId: m.dataset['extended_pan_id'] ?? '',
          meshLocalPrefix: m.dataset['mesh_local_prefix'] ?? '',
          panId: m.dataset['pan_id'] ?? 0,
          channel: m.dataset['channel'] ?? 0,
        ));
        break;

      case UnicastAddressListMessage _:
        final m = msg as UnicastAddressListMessage;
        break;

      case MulticastAddressListMessage _:
        final m = msg as MulticastAddressListMessage;
        break;

      case MeshcopServiceStatusMessage _:
        final m = msg as MeshcopServiceStatusMessage;
        break;

      case WifiStaStatusMessage _:
        final m = msg as WifiStaStatusMessage;
        break;

      case MatterCommissioningCompleteMessage _:
        final m = msg as MatterCommissioningCompleteMessage;
        break;

      case MatterAttributeReportMessage _:
        final m = msg as MatterAttributeReportMessage;
        break;

      case MatterSubscribeDoneMessage _:
        final m = msg as MatterSubscribeDoneMessage;
        break;

      case GenericMessage _:
        final m = msg as GenericMessage;
        _logger.i('Received generic message: ${m.type}/${m.action ?? 'n/a'} - ${m.payload}');
        break;

      default:
        _logger.w('Unhandled message type: ${msg.runtimeType}');
        break;
    }
  }
}

class MessageParseException implements Exception {
  final String message;
  const MessageParseException(this.message);
  @override
  String toString() => 'MessageParseException: $message';
}
