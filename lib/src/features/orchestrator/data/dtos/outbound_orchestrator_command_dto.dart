import 'dart:convert';

final class OutboundOrchestratorCommandDto {
  final String action;
  final Map<String, Object?>? payload;

  const OutboundOrchestratorCommandDto({
    required this.action,
    this.payload,
  });

  String toJsonString() {
    return jsonEncode({
      'type': 'command',
      'action': action,
      if (payload != null) 'payload': payload,
    });
  }
}
