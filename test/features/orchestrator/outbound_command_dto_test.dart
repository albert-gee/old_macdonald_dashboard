import 'dart:convert';

import 'package:dashboard/src/features/orchestrator/data/dtos/outbound_orchestrator_command_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('outbound command always includes object payload', () {
    final body = jsonDecode(
      const OutboundOrchestratorCommandDto(
        action: 'thread.enable',
      ).toJsonString(),
    ) as Map<String, Object?>;

    expect(body, {
      'type': 'command',
      'action': 'thread.enable',
      'payload': <String, Object?>{},
    });
  });
}
