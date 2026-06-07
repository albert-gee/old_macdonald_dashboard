import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_message.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/pending_orchestrator_command.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_command_client.dart';
import 'orchestrator_runtime_state.dart';

final class OrchestratorRuntimeController
    extends StateNotifier<OrchestratorRuntimeState> {
  final StreamSubscription<OrchestratorMessage> _messageSubscription;
  final StreamSubscription<Map<String, PendingOrchestratorCommand>>
  _pendingSubscription;

  OrchestratorRuntimeController({
    required Stream<OrchestratorMessage> messages,
    required OrchestratorCommandClient commandClient,
  }) : _messageSubscription = messages.listen((_) {}),
       _pendingSubscription = commandClient.pendingCommandsStream.listen(
         (_) {},
       ),
       super(
         OrchestratorRuntimeState(
           pendingCommands: commandClient.pendingCommands,
         ),
       ) {
    _messageSubscription
      ..onData(_onMessage)
      ..onError((Object error, StackTrace stackTrace) {
        state = state.copyWith(lastError: error.toString());
      });
    _pendingSubscription.onData((pending) {
      state = state.copyWith(pendingCommands: pending);
    });
  }

  @override
  void dispose() {
    _messageSubscription.cancel();
    _pendingSubscription.cancel();
    super.dispose();
  }

  void _onMessage(OrchestratorMessage message) {
    final receivedAt = DateTime.now();
    _recordMessage(message, receivedAt);
    switch (message) {
      case StateSnapshotReceived(snapshot: final snapshot):
        state = state.copyWith(
          snapshot: snapshot,
          lastMessageAt: receivedAt,
          lastSnapshotAt: receivedAt,
          clearLastError: true,
        );
      case OrchestratorEventReceived(
        event: final event,
        payload: final payload,
        receivedAt: final eventReceivedAt,
      ):
        _appendEvent(
          OrchestratorEventLogEntry(
            type: event,
            payload: payload,
            receivedAt: eventReceivedAt,
          ),
        );
      case OrchestratorProtocolErrorReceived(
        code: final code,
        message: final errorMessage,
      ):
        _appendEvent(
          OrchestratorEventLogEntry(
            type: 'error.$code',
            payload: {'message': errorMessage},
            receivedAt: receivedAt,
          ),
          lastError: errorMessage,
        );
      case CommandResultReceived(result: final result) when !result.ok:
        _appendEvent(
          OrchestratorEventLogEntry(
            type: 'command_failed.${result.action}',
            payload: {
              'request_id': result.requestId,
              'message': result.error?.message ?? 'Command failed.',
            },
            receivedAt: receivedAt,
          ),
          lastError: result.error?.message ?? 'Command failed.',
        );
      default:
        state = state.copyWith(lastMessageAt: receivedAt);
    }
  }

  void _recordMessage(OrchestratorMessage message, DateTime receivedAt) {
    final entry = switch (message) {
      StateSnapshotReceived(snapshot: final snapshot) =>
        OrchestratorProtocolLogEntry(
          title: 'state_snapshot',
          direction: 'in',
          payload: snapshot.rawPayload,
          receivedAt: receivedAt,
        ),
      CommandResultReceived(result: final result) =>
        OrchestratorProtocolLogEntry(
          title: 'command_result.${result.action}',
          direction: 'in',
          payload: {
            'request_id': result.requestId,
            'action': result.action,
            'ok': result.ok,
            'payload': result.payload,
            if (result.error != null)
              'error': {
                'code': result.error!.code,
                'message': result.error!.message,
              },
          },
          receivedAt: receivedAt,
          error: !result.ok,
        ),
      OrchestratorEventReceived(event: final event, payload: final payload) =>
        OrchestratorProtocolLogEntry(
          title: 'event.$event',
          direction: 'in',
          payload: payload,
          receivedAt: receivedAt,
        ),
      OrchestratorProtocolErrorReceived(
        code: final code,
        message: final errorMessage,
      ) =>
        OrchestratorProtocolLogEntry(
          title: 'protocol_error.$code',
          direction: 'in',
          payload: {'code': code, 'message': errorMessage},
          receivedAt: receivedAt,
          error: true,
        ),
      ThreadStackStatusReceived(:final running) => OrchestratorProtocolLogEntry(
        title: 'info.thread.stack_status',
        direction: 'in',
        payload: {'running': running},
        receivedAt: receivedAt,
      ),
      ThreadInterfaceStatusReceived(:final interfaceUp) =>
        OrchestratorProtocolLogEntry(
          title: 'info.thread.interface_status',
          direction: 'in',
          payload: {'interface_up': interfaceUp},
          receivedAt: receivedAt,
        ),
      ThreadAttachmentStatusReceived(:final attached) =>
        OrchestratorProtocolLogEntry(
          title: 'info.thread.attachment_status',
          direction: 'in',
          payload: {'attached': attached},
          receivedAt: receivedAt,
        ),
      ThreadRoleReceived(:final role) => OrchestratorProtocolLogEntry(
        title: 'info.thread.role',
        direction: 'in',
        payload: {'role': role},
        receivedAt: receivedAt,
      ),
      ThreadActiveDatasetReceived(dataset: final dataset) =>
        OrchestratorProtocolLogEntry(
          title: 'info.thread.active_dataset',
          direction: 'in',
          payload: {
            'network_name': dataset.networkName,
            'channel': dataset.channel,
            'pan_id': dataset.panId,
            'extended_pan_id': dataset.extendedPanId,
            'mesh_local_prefix': dataset.meshLocalPrefix,
          },
          receivedAt: receivedAt,
        ),
      UnknownOrchestratorMessageReceived(
        type: final type,
        action: final action,
        payload: final payload,
      ) =>
        OrchestratorProtocolLogEntry(
          title: action == null ? type : '$type.$action',
          direction: 'in',
          payload: payload,
          receivedAt: receivedAt,
        ),
      _ => OrchestratorProtocolLogEntry(
        title: message.runtimeType.toString(),
        direction: 'in',
        payload: const {},
        receivedAt: receivedAt,
      ),
    };
    final messages = [entry, ...state.recentMessages].take(100).toList();
    state = state.copyWith(recentMessages: messages, lastMessageAt: receivedAt);
  }

  void _appendEvent(OrchestratorEventLogEntry entry, {String? lastError}) {
    final events = [entry, ...state.recentEvents].take(100).toList();
    state = state.copyWith(recentEvents: events, lastError: lastError);
  }
}
