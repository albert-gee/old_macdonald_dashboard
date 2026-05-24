import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_command_result.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/pending_orchestrator_command.dart';

abstract interface class OrchestratorCommandClient {
  Map<String, PendingOrchestratorCommand> get pendingCommands;

  Stream<Map<String, PendingOrchestratorCommand>> get pendingCommandsStream;

  Future<Result<OrchestratorCommandResult>> sendCommand(
    String action, {
    Map<String, Object?> payload = const <String, Object?>{},
    Duration timeout = const Duration(seconds: 10),
  });
}
