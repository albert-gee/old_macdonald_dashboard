import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/core/websocket/websocket_client.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_settings.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_status.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_connection_repository.dart';

final class OrchestratorConnectionRepositoryImpl
    implements OrchestratorConnectionRepository {
  final WebSocketClient _webSocketClient;

  OrchestratorConnectionRepositoryImpl(
      {required WebSocketClient webSocketClient})
      : _webSocketClient = webSocketClient;

  @override
  bool get isConnected => _webSocketClient.isConnected;

  @override
  Stream<WebSocketConnectionStatus> get status => _webSocketClient.status;

  @override
  Future<Result<void>> connect(WebSocketConnectionSettings settings) {
    return _webSocketClient.connect(settings);
  }

  @override
  Future<Result<void>> sendRaw(String message) =>
      _webSocketClient.send(message);

  @override
  Future<void> disconnect() => _webSocketClient.disconnect();
}
