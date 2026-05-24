import 'dart:convert';

final class OutboundOrchestratorCommandDto {
  final String requestId;
  final String action;
  final Map<String, Object?> payload;

  const OutboundOrchestratorCommandDto({
    required this.requestId,
    required this.action,
    this.payload = const <String, Object?>{},
  });

  String toJsonString() {
    return jsonEncode({
      'type': 'command',
      'request_id': requestId,
      'action': action,
      'payload': payload,
    });
  }
}
