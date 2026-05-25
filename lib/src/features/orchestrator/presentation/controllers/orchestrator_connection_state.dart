import 'package:dashboard/src/core/websocket/websocket_connection_status.dart';

final class OrchestratorConnectionState {
  final String url;
  final WebSocketConnectionStatus status;
  final bool loading;
  final bool pairing;
  final String? host;
  final String? trustedFingerprint;
  final String? observedFingerprint;
  final String? message;
  final bool success;

  const OrchestratorConnectionState({
    required this.url,
    this.status = WebSocketConnectionStatus.disconnected,
    this.loading = false,
    this.pairing = false,
    this.host,
    this.trustedFingerprint,
    this.observedFingerprint,
    this.message,
    this.success = false,
  });

  OrchestratorConnectionState copyWith({
    String? url,
    WebSocketConnectionStatus? status,
    bool? loading,
    bool? pairing,
    String? host,
    String? trustedFingerprint,
    String? observedFingerprint,
    String? message,
    bool? success,
    bool clearMessage = false,
    bool clearTrustedFingerprint = false,
    bool clearObservedFingerprint = false,
  }) {
    return OrchestratorConnectionState(
      url: url ?? this.url,
      status: status ?? this.status,
      loading: loading ?? this.loading,
      pairing: pairing ?? this.pairing,
      host: host ?? this.host,
      trustedFingerprint: clearTrustedFingerprint
          ? null
          : trustedFingerprint ?? this.trustedFingerprint,
      observedFingerprint: clearObservedFingerprint
          ? null
          : observedFingerprint ?? this.observedFingerprint,
      message: clearMessage ? null : message ?? this.message,
      success: success ?? this.success,
    );
  }
}
