import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_snapshot.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/pending_orchestrator_command.dart';

final class OrchestratorEventLogEntry {
  final String type;
  final Map<String, Object?> payload;
  final DateTime receivedAt;

  const OrchestratorEventLogEntry({
    required this.type,
    required this.payload,
    required this.receivedAt,
  });
}

final class OrchestratorProtocolLogEntry {
  final String title;
  final String direction;
  final Map<String, Object?> payload;
  final DateTime receivedAt;
  final bool error;

  const OrchestratorProtocolLogEntry({
    required this.title,
    required this.direction,
    required this.payload,
    required this.receivedAt,
    this.error = false,
  });
}

final class OrchestratorRuntimeState {
  final OrchestratorSnapshot? snapshot;
  final DateTime? lastMessageAt;
  final DateTime? lastSnapshotAt;
  final List<OrchestratorProtocolLogEntry> recentMessages;
  final List<OrchestratorEventLogEntry> recentEvents;
  final Map<String, PendingOrchestratorCommand> pendingCommands;
  final String? lastError;

  const OrchestratorRuntimeState({
    this.snapshot,
    this.lastMessageAt,
    this.lastSnapshotAt,
    this.recentMessages = const [],
    this.recentEvents = const [],
    this.pendingCommands = const {},
    this.lastError,
  });

  OrchestratorRuntimeState copyWith({
    OrchestratorSnapshot? snapshot,
    DateTime? lastMessageAt,
    DateTime? lastSnapshotAt,
    List<OrchestratorProtocolLogEntry>? recentMessages,
    List<OrchestratorEventLogEntry>? recentEvents,
    Map<String, PendingOrchestratorCommand>? pendingCommands,
    String? lastError,
    bool clearLastError = false,
  }) {
    return OrchestratorRuntimeState(
      snapshot: snapshot ?? this.snapshot,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastSnapshotAt: lastSnapshotAt ?? this.lastSnapshotAt,
      recentMessages: recentMessages ?? this.recentMessages,
      recentEvents: recentEvents ?? this.recentEvents,
      pendingCommands: pendingCommands ?? this.pendingCommands,
      lastError: clearLastError ? null : lastError ?? this.lastError,
    );
  }
}
