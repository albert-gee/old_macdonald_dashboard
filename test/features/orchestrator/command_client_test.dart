import 'dart:async';
import 'dart:convert';

import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/orchestrator/data/repositories/orchestrator_command_client_impl.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_command_result.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_message.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_message_repository.dart';
import 'package:dashboard/src/features/orchestrator/domain/services/orchestrator_request_id_generator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

import '../../fakes.dart';

void main() {
  test('completes pending command on matching request_id', () async {
    final messages = _MessageRepo();
    final connection = RecordingConnectionRepository();
    final client = OrchestratorCommandClientImpl(
      connectionRepository: connection,
      messageRepository: messages,
      requestIdGenerator: _Ids(['req-1']),
      logger: Logger(),
    );

    final future = client.sendCommand('thread.status_get');
    expect(client.pendingCommands, contains('req-1'));
    messages.add(
      const CommandResultReceived(
        OrchestratorCommandResult(
          requestId: 'req-1',
          action: 'thread.status_get',
          ok: true,
          payload: {'enabled': true},
        ),
      ),
    );

    final result = await future;
    expect(result, isA<Success<OrchestratorCommandResult>>());
    expect(client.pendingCommands, isEmpty);
    final sent = jsonDecode(connection.sent.single) as Map<String, Object?>;
    expect(sent['request_id'], 'req-1');
    await client.dispose();
    await messages.close();
  });

  test('ignores unrelated request_id and times out', () async {
    final messages = _MessageRepo();
    final client = OrchestratorCommandClientImpl(
      connectionRepository: RecordingConnectionRepository(),
      messageRepository: messages,
      requestIdGenerator: _Ids(['req-1']),
      logger: Logger(),
    );

    final future = client.sendCommand(
      'thread.status_get',
      timeout: const Duration(milliseconds: 10),
    );
    messages.add(
      const CommandResultReceived(
        OrchestratorCommandResult(
          requestId: 'other',
          action: 'thread.status_get',
          ok: true,
          payload: {},
        ),
      ),
    );

    final result = await future;
    expect(result, isA<FailureResult<OrchestratorCommandResult>>());
    expect(client.pendingCommands, isEmpty);
    await client.dispose();
    await messages.close();
  });
}

final class _MessageRepo implements OrchestratorMessageRepository {
  final _controller = StreamController<OrchestratorMessage>.broadcast();

  @override
  Stream<OrchestratorMessage> watchMessages() => _controller.stream;

  void add(OrchestratorMessage message) => _controller.add(message);

  Future<void> close() => _controller.close();
}

final class _Ids implements OrchestratorRequestIdGenerator {
  final List<String> ids;
  int index = 0;

  _Ids(this.ids);

  @override
  String next() => ids[index++];
}
