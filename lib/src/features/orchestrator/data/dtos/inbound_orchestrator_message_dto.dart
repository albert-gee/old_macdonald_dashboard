import 'dart:convert';

import 'package:dashboard/src/core/errors/app_failure.dart';
import 'package:dashboard/src/core/errors/result.dart';

final class InboundOrchestratorMessageDto {
  final String type;
  final String? requestId;
  final String? action;
  final bool? ok;
  final String? event;
  final Map<String, Object?> payload;
  final Map<String, Object?>? error;

  const InboundOrchestratorMessageDto({
    required this.type,
    this.requestId,
    this.action,
    this.ok,
    this.event,
    this.payload = const <String, Object?>{},
    this.error,
  });

  static Result<InboundOrchestratorMessageDto> fromJsonString(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is! Map<String, Object?>) {
        return const FailureResult(
          MessageParseFailure('Expected JSON object.'),
        );
      }
      return Success(InboundOrchestratorMessageDto.fromJson(decoded));
    } catch (error) {
      return const FailureResult(
        MessageParseFailure('Unable to parse message.'),
      );
    }
  }

  factory InboundOrchestratorMessageDto.fromJson(Map<String, Object?> json) {
    final rawPayload = json['payload'];
    final rawError = json['error'];
    return InboundOrchestratorMessageDto(
      type: json['type'] is String ? json['type'] as String : '',
      requestId: json['request_id'] is String
          ? json['request_id'] as String
          : null,
      action: json['action'] is String ? json['action'] as String : null,
      ok: json['ok'] is bool ? json['ok'] as bool : null,
      event: json['event'] is String ? json['event'] as String : null,
      payload: rawPayload is Map
          ? rawPayload.map((key, value) => MapEntry(key.toString(), value))
          : const <String, Object?>{},
      error: rawError is Map
          ? rawError.map((key, value) => MapEntry(key.toString(), value))
          : null,
    );
  }
}
