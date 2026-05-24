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

final class OrchestratorRuntimeState {
  final OrchestratorSnapshot? snapshot;
  final List<OrchestratorEventLogEntry> recentEvents;
  final Map<String, PendingOrchestratorCommand> pendingCommands;
  final String? lastError;

  const OrchestratorRuntimeState({
    this.snapshot,
    this.recentEvents = const [],
    this.pendingCommands = const {},
    this.lastError,
  });

  OrchestratorRuntimeState copyWith({
    OrchestratorSnapshot? snapshot,
    List<OrchestratorEventLogEntry>? recentEvents,
    Map<String, PendingOrchestratorCommand>? pendingCommands,
    String? lastError,
    bool clearLastError = false,
  }) {
    return OrchestratorRuntimeState(
      snapshot: snapshot ?? this.snapshot,
      recentEvents: recentEvents ?? this.recentEvents,
      pendingCommands: pendingCommands ?? this.pendingCommands,
      lastError: clearLastError ? null : lastError ?? this.lastError,
    );
  }
}
