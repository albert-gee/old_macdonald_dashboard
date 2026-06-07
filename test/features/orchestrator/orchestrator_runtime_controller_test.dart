import 'dart:async';

import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_message.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_command_result.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_snapshot.dart';
import 'package:dashboard/src/features/orchestrator/presentation/controllers/orchestrator_runtime_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes.dart';

void main() {
  test('updates snapshot and recent events from message stream', () async {
    final messages = StreamController<OrchestratorMessage>();
    final controller = OrchestratorRuntimeController(
      messages: messages.stream,
      commandClient: RecordingCommandClient(),
    );

    messages.add(
      StateSnapshotReceived(
        OrchestratorSnapshot.fromPayload({
          'wifi': {'ap_running': true},
        }),
      ),
    );
    messages.add(
      OrchestratorEventReceived(
        event: 'wifi.sta_connected',
        payload: const {'ip': '192.168.1.2'},
        receivedAt: DateTime(2026),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.snapshot?.wifi.apRunning, isTrue);
    expect(controller.state.recentEvents.single.type, 'wifi.sta_connected');
    expect(
      controller.state.recentMessages.map((entry) => entry.title),
      containsAll(['state_snapshot', 'event.wifi.sta_connected']),
    );
    await messages.close();
    controller.dispose();
  });

  test(
    'records failed command results in protocol log and last error',
    () async {
      final messages = StreamController<OrchestratorMessage>();
      final controller = OrchestratorRuntimeController(
        messages: messages.stream,
        commandClient: RecordingCommandClient(),
      );

      messages.add(
        CommandResultReceived(
          OrchestratorCommandResult(
            requestId: 'req-1',
            action: 'matter.controller_init',
            ok: false,
            payload: const {},
            error: const OrchestratorCommandError(
              code: 'MATTER_PLATFORM_NOT_INITIALIZED',
              message: 'Matter platform is not initialized.',
            ),
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.lastError, 'Matter platform is not initialized.');
      expect(
        controller.state.recentEvents.single.type,
        'command_failed.matter.controller_init',
      );
      expect(controller.state.recentMessages.single.error, isTrue);
      expect(
        controller.state.recentMessages.single.payload['error'],
        isA<Map<String, Object?>>(),
      );

      await messages.close();
      controller.dispose();
    },
  );
}
