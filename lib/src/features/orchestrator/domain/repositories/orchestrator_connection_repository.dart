import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_settings.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_status.dart';

abstract interface class OrchestratorConnectionRepository {
  bool get isConnected;
  Stream<WebSocketConnectionStatus> get status;

  Future<Result<void>> connect(WebSocketConnectionSettings settings);

  Future<Result<void>> sendRaw(String message);

  Future<void> disconnect();
}
