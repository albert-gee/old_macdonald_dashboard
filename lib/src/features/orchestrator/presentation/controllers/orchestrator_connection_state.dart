import 'package:dashboard/src/core/websocket/websocket_connection_status.dart';

final class OrchestratorConnectionState {
  final String url;
  final WebSocketConnectionStatus status;
  final bool loading;
  final String? message;
  final bool success;

  const OrchestratorConnectionState({
    required this.url,
    this.status = WebSocketConnectionStatus.disconnected,
    this.loading = false,
    this.message,
    this.success = false,
  });

  OrchestratorConnectionState copyWith({
    String? url,
    WebSocketConnectionStatus? status,
    bool? loading,
    String? message,
    bool? success,
    bool clearMessage = false,
  }) {
    return OrchestratorConnectionState(
      url: url ?? this.url,
      status: status ?? this.status,
      loading: loading ?? this.loading,
      message: clearMessage ? null : message ?? this.message,
      success: success ?? this.success,
    );
  }
}
