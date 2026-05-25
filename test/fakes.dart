import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_settings.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_status.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_command_result.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/pending_orchestrator_command.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_command_client.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_connection_repository.dart';

final class RecordingConnectionRepository
    implements OrchestratorConnectionRepository {
  final List<String> sent = [];
  Result<void> sendResult;

  RecordingConnectionRepository({this.sendResult = const Success(null)});

  @override
  bool get isConnected => true;

  @override
  Stream<WebSocketConnectionStatus> get status => const Stream.empty();

  @override
  Stream<String> get observedCertificateFingerprints => const Stream.empty();

  @override
  Future<Result<void>> connect(WebSocketConnectionSettings settings) async =>
      const Success(null);

  @override
  Future<void> disconnect() async {}

  @override
  Future<Result<void>> sendRaw(String message) async {
    sent.add(message);
    return sendResult;
  }
}

final class RecordingCommandClient implements OrchestratorCommandClient {
  final List<RecordedCommand> commands = [];
  Result<OrchestratorCommandResult>? nextResult;

  @override
  Map<String, PendingOrchestratorCommand> get pendingCommands => const {};

  @override
  Stream<Map<String, PendingOrchestratorCommand>> get pendingCommandsStream =>
      const Stream.empty();

  @override
  Future<Result<OrchestratorCommandResult>> sendCommand(
    String action, {
    Map<String, Object?> payload = const <String, Object?>{},
    Duration timeout = const Duration(seconds: 10),
  }) async {
    commands.add(RecordedCommand(action: action, payload: payload));
    return nextResult ??
        Success(
          OrchestratorCommandResult(
            requestId: 'req-${commands.length}',
            action: action,
            ok: true,
            payload: const {},
          ),
        );
  }
}

final class RecordedCommand {
  final String action;
  final Map<String, Object?> payload;

  const RecordedCommand({required this.action, required this.payload});
}
