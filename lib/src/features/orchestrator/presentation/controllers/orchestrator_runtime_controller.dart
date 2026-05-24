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
    switch (message) {
      case StateSnapshotReceived(snapshot: final snapshot):
        state = state.copyWith(snapshot: snapshot, clearLastError: true);
      case OrchestratorEventReceived(
        event: final event,
        payload: final payload,
        receivedAt: final receivedAt,
      ):
        _appendEvent(
          OrchestratorEventLogEntry(
            type: event,
            payload: payload,
            receivedAt: receivedAt,
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
            receivedAt: DateTime.now(),
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
            receivedAt: DateTime.now(),
          ),
          lastError: result.error?.message ?? 'Command failed.',
        );
      default:
        break;
    }
  }

  void _appendEvent(OrchestratorEventLogEntry entry, {String? lastError}) {
    final events = [entry, ...state.recentEvents].take(100).toList();
    state = state.copyWith(recentEvents: events, lastError: lastError);
  }
}
