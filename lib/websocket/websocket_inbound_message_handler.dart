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
import 'package:dashboard/websocket/websocket_inbound_message.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class WebSocketInboundMessageHandler {
  final Logger _logger = Logger();

  void handle(String rawMessage) {
    try {
      final decoded = jsonDecode(rawMessage);
      if (decoded is! Map<String, dynamic>) {
        throw MessageParseException('Expected JSON object');
      }

      final msg = WebSocketInboundMessage.fromJson(decoded);
      _dispatchMessage(msg);
    } catch (e) {
      _logger.e('Failed to parse WebSocket message', error: e);
    }
  }

  void _dispatchMessage(WebSocketInboundMessage msg) {
    final getIt = GetIt.I;

    if (msg is ThreadStackStatusMessage) {
      getIt<ThreadStackStatusBloc>().add(ThreadStackStatusUpdated(msg.running));
    } else if (msg is ThreadInterfaceStatusMessage) {
      getIt<ThreadInterfaceStatusBloc>().add(ThreadInterfaceStatusUpdated(msg.interfaceUp));
    } else if (msg is ThreadAttachmentStatusMessage) {
      getIt<ThreadAttachmentStatusBloc>().add(ThreadAttachmentStatusUpdated(msg.attached));
    } else if (msg is ThreadRoleMessage) {
      getIt<ThreadRoleBloc>().add(ThreadRoleUpdated(msg.role));
    } else if (msg is ThreadDatasetActiveMessage) {
      getIt<ThreadActiveDatasetBloc>().add(
        ThreadActiveDatasetUpdated(
          activeTimestamp: msg.dataset['active_timestamp'] ?? 0,
          networkName: msg.dataset['network_name'] ?? '',
          extendedPanId: msg.dataset['extended_pan_id'] ?? '',
          meshLocalPrefix: msg.dataset['mesh_local_prefix'] ?? '',
          panId: msg.dataset['pan_id'] ?? 0,
          channel: msg.dataset['channel'] ?? 0,
        ),
      );
    } else if (msg is GenericMessage) {
      _logger.i('Received generic message: ${msg.type}/${msg.action ?? 'n/a'} - ${msg.payload}');
    } else if (msg is UnicastAddressListMessage ||
        msg is MulticastAddressListMessage ||
        msg is MeshcopServiceStatusMessage ||
        msg is WifiStaStatusMessage ||
        msg is MatterCommissioningCompleteMessage ||
        msg is MatterAttributeReportMessage ||
        msg is MatterSubscribeDoneMessage) {
      // Placeholders for unhandled messages — can be extended in the future.
    } else {
      _logger.w('Unhandled message type: ${msg.runtimeType}');
    }
  }
}

class MessageParseException implements Exception {
  final String message;
  const MessageParseException(this.message);
  @override
  String toString() => 'MessageParseException: $message';
}
