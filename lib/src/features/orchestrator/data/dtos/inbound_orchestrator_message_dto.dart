import 'dart:convert';

import 'package:dashboard/src/core/errors/app_failure.dart';
import 'package:dashboard/src/core/errors/result.dart';

final class InboundOrchestratorMessageDto {
  final String type;
  final String? action;
  final Map<String, Object?> payload;

  const InboundOrchestratorMessageDto({
    required this.type,
    required this.action,
    required this.payload,
  });

  static Result<InboundOrchestratorMessageDto> fromJsonString(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is! Map<String, Object?>) {
        return const FailureResult(
            MessageParseFailure('Expected JSON object.'));
      }
      return Success(InboundOrchestratorMessageDto.fromJson(decoded));
    } catch (error) {
      return const FailureResult(
          MessageParseFailure('Unable to parse message.'));
    }
  }

  factory InboundOrchestratorMessageDto.fromJson(Map<String, Object?> json) {
    final rawPayload = json['payload'];
    return InboundOrchestratorMessageDto(
      type: json['type'] is String ? json['type'] as String : '',
      action: json['action'] is String ? json['action'] as String : null,
      payload: rawPayload is Map
          ? rawPayload.map((key, value) => MapEntry(key.toString(), value))
          : const <String, Object?>{},
    );
  }
}
