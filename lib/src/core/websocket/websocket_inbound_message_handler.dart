import 'dart:convert';

import 'package:dashboard/src/features/thread/presentation/blocs/thread_active_dataset/thread_active_dataset_bloc.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_active_dataset/thread_active_dataset_event.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_address/thread_address_bloc.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_address/thread_address_event.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_attachment_status/thread_attachment_status_bloc.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_attachment_status/thread_attachment_status_event.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_interface_status/thread_interface_status_bloc.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_interface_status/thread_interface_status_event.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_meshcop_service_status/thread_meshcop_service_status_bloc.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_meshcop_service_status/thread_meshcop_service_status_event.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_role/thread_role_bloc.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_role/thread_role_event.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_stack_status/thread_stack_status_bloc.dart';
import 'package:dashboard/src/features/thread/presentation/blocs/thread_stack_status/thread_stack_status_event.dart';
import 'package:dashboard/src/core/websocket/websocket_inbound_message.dart';
import 'package:logger/logger.dart';

class WebSocketInboundMessageHandler {
  final ThreadStackStatusBloc threadStackStatusBloc;
  final ThreadInterfaceStatusBloc threadInterfaceStatusBloc;
  final ThreadAttachmentStatusBloc threadAttachmentStatusBloc;
  final ThreadRoleBloc threadRoleBloc;
  final ThreadActiveDatasetBloc threadActiveDatasetBloc;
  final ThreadAddressBloc threadAddressBloc;
  final ThreadMeshcopServiceStatusBloc threadMeshcopServiceStatusBloc;
  final Logger _logger = Logger();

  WebSocketInboundMessageHandler({
    required this.threadStackStatusBloc,
    required this.threadInterfaceStatusBloc,
    required this.threadAttachmentStatusBloc,
    required this.threadRoleBloc,
    required this.threadActiveDatasetBloc,
    required this.threadAddressBloc,
    required this.threadMeshcopServiceStatusBloc,
  });

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
    if (msg is ThreadStackStatusMessage) {
      threadStackStatusBloc.add(ThreadStackStatusUpdated(msg.running));
    } else if (msg is ThreadInterfaceStatusMessage) {
      threadInterfaceStatusBloc
          .add(ThreadInterfaceStatusUpdated(msg.interfaceUp));
    } else if (msg is ThreadAttachmentStatusMessage) {
      threadAttachmentStatusBloc
          .add(ThreadAttachmentStatusUpdated(msg.attached));
    } else if (msg is ThreadRoleMessage) {
      threadRoleBloc.add(ThreadRoleUpdated(msg.role));
    } else if (msg is ThreadDatasetActiveMessage) {
      threadActiveDatasetBloc.add(
        ThreadActiveDatasetUpdated(
          activeTimestamp: _intValue(msg.dataset['active_timestamp']),
          networkName: _stringValue(msg.dataset['network_name']),
          extendedPanId: _stringValue(msg.dataset['extended_pan_id']),
          meshLocalPrefix: _stringValue(msg.dataset['mesh_local_prefix']),
          panId: _intValue(msg.dataset['pan_id']),
          channel: _intValue(msg.dataset['channel']),
        ),
      );
    } else if (msg is UnicastAddressListMessage) {
      threadAddressBloc.add(ThreadUnicastAddressesUpdated(msg.addresses));
    } else if (msg is MulticastAddressListMessage) {
      threadAddressBloc.add(ThreadMulticastAddressesUpdated(msg.addresses));
    } else if (msg is MeshcopServiceStatusMessage) {
      threadMeshcopServiceStatusBloc.add(
        ThreadMeshcopServiceStatusUpdated(msg.published),
      );
    } else if (msg is GenericMessage) {
      _logger.i(
          'Received generic message: ${msg.type}/${msg.action ?? 'n/a'} - ${msg.payload}');
    } else if (msg is WifiStaStatusMessage ||
        msg is MatterCommissioningCompleteMessage ||
        msg is MatterAttributeReportMessage ||
        msg is MatterSubscribeDoneMessage) {
      _logger.i('Received message: ${msg.type}/${msg.action ?? 'n/a'}');
    } else {
      _logger.w('Unhandled message type: ${msg.runtimeType}');
    }
  }

  int _intValue(Object? value) => value is int ? value : 0;

  String _stringValue(Object? value) => value is String ? value : '';
}

class MessageParseException implements Exception {
  final String message;
  const MessageParseException(this.message);
  @override
  String toString() => 'MessageParseException: $message';
}
