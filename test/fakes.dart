import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_settings.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_status.dart';
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
