import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_message.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_message_repository.dart';
import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/features/thread/data/repositories/thread_command_repository_impl.dart';
import 'package:dashboard/src/features/thread/domain/entities/thread_active_dataset.dart';
import 'package:dashboard/src/features/thread/domain/entities/thread_dataset_init_request.dart';
import 'package:dashboard/src/features/thread/domain/entities/thread_readiness.dart';
import 'package:dashboard/src/features/thread/domain/repositories/thread_command_repository.dart';
import 'package:dashboard/src/features/thread/presentation/screens/thread_screen.dart';
import 'package:dashboard/src/features/thread/presentation/controllers/thread_status_controller.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_command_result.dart';
import 'package:dashboard/src/core/errors/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes.dart';

void main() {
  test('readiness derives stopped from enabled=false', () {
    final readiness = ThreadReadiness.derive(
      connected: true,
      hasThreadData: true,
      enabled: false,
      datasetPresent: false,
      attached: false,
    );
    expect(readiness.state, ThreadReadinessState.stopped);
  });

  test('readiness derives missingDataset from running without dataset', () {
    final readiness = ThreadReadiness.derive(
      connected: true,
      hasThreadData: true,
      enabled: true,
      datasetPresent: false,
      attached: false,
    );
    expect(readiness.state, ThreadReadinessState.missingDataset);
  });

  test('readiness derives detached from dataset present but detached', () {
    final readiness = ThreadReadiness.derive(
      connected: true,
      hasThreadData: true,
      enabled: true,
      datasetPresent: true,
      attached: false,
    );
    expect(readiness.state, ThreadReadinessState.detached);
  });

  test('readiness derives inferred ready from attached with dataset', () {
    final readiness = ThreadReadiness.derive(
      connected: true,
      hasThreadData: true,
      enabled: true,
      datasetPresent: true,
      attached: true,
    );
    expect(readiness.state, ThreadReadinessState.readyForCommissioning);
    expect(readiness.commissioningReadinessInferred, isTrue);
  });

  test('command repository encodes every Thread action', () async {
    final client = RecordingCommandClient();
    final repository = ThreadCommandRepositoryImpl(client: client);

    await repository.enable();
    await repository.disable();
    await repository.refreshStatus();
    await repository.refreshAttachment();
    await repository.refreshRole();
    await repository.refreshActiveDataset();
    await repository.refreshUnicastAddresses();
    await repository.refreshMulticastAddresses();
    await repository.initBorderRouter();
    await repository.deinitBorderRouter();

    expect(client.commands.map((command) => command.action), [
      'thread.enable',
      'thread.disable',
      'thread.status_get',
      'thread.attached_get',
      'thread.role_get',
      'thread.active_dataset_get',
      'thread.unicast_addresses_get',
      'thread.multicast_addresses_get',
      'thread.br_init',
      'thread.br_deinit',
    ]);
  });

  test('dataset init encodes master_key', () async {
    final client = RecordingCommandClient();
    final repository = ThreadCommandRepositoryImpl(client: client);

    await repository.initDataset(
      const ThreadDatasetInitRequest(
        channel: 15,
        panId: 1,
        networkName: 'mesh',
        extendedPanId: 'epan',
        meshLocalPrefix: 'fd00::/64',
        networkKey: 'key',
        pskc: 'pskc',
      ),
    );

    final command = client.commands.single;
    final payload = command.payload;
    expect(command.action, 'thread.dataset.init');
    expect(payload, {
      'channel': 15,
      'pan_id': 1,
      'network_name': 'mesh',
      'extended_pan_id': 'epan',
      'mesh_local_prefix': 'fd00::/64',
      'master_key': 'key',
      'pskc': 'pskc',
    });
    expect(payload['master_key'], 'key');
    expect(payload.containsKey('network_key'), isFalse);
  });

  test('status controller updates from orchestrator messages', () async {
    final stream = Stream<OrchestratorMessage>.fromIterable([
      const ThreadStackStatusReceived(true),
      const ThreadRoleReceived('leader'),
    ]);
    final controller = ThreadStatusController(messages: stream);
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.status.stackRunning, isTrue);
    expect(controller.state.status.role, 'leader');
  });

  testWidgets('Thread page renders readiness card', (tester) async {
    await _pumpThreadScreen(tester);

    expect(find.text('Thread Network Readiness'), findsOneWidget);
  });

  testWidgets('Thread page does not show raw command dump as first section', (
    tester,
  ) async {
    await _pumpThreadScreen(tester);

    expect(find.text('Thread Network Readiness'), findsOneWidget);
    expect(find.text('Thread Commands'), findsNothing);
    expect(find.text('Raw Thread command buttons'), findsOneWidget);
  });

  testWidgets('dataset summary does not expose secrets in normal UI', (
    tester,
  ) async {
    await _pumpThreadScreen(
      tester,
      messages: const [
        ThreadStackStatusReceived(true),
        ThreadMeshcopServiceStatusReceived(true),
        ThreadActiveDatasetReceived(
          ThreadActiveDataset(networkName: 'mesh', channel: 15, panId: 4660),
        ),
      ],
    );

    expect(find.text('Dataset Summary'), findsOneWidget);
    expect(find.text('Network name: mesh'), findsOneWidget);
    expect(find.text('Network key'), findsNothing);
    expect(find.text('Master key'), findsNothing);
    expect(find.text('PSKc'), findsNothing);
  });

  testWidgets('manual dataset form is advanced-only', (tester) async {
    await _pumpThreadScreen(tester);

    expect(find.text('Network key'), findsNothing);
    await _tapVisible(
      tester,
      find.text('Advanced manual dataset initialization'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Network key'), findsOneWidget);
    expect(
      find.text(
        'This form is for development and recovery. It exposes low-level Thread network credentials.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('operator Start Thread sends thread.enable', (tester) async {
    final repository = _RecordingThreadRepository();
    await _pumpThreadScreen(tester, repository: repository);

    await _tapVisible(tester, find.text('Start Thread'));
    await tester.pump();

    expect(repository.actions, contains('thread.enable'));
  });

  testWidgets('operator Stop Thread sends thread.disable', (tester) async {
    final repository = _RecordingThreadRepository();
    await _pumpThreadScreen(
      tester,
      repository: repository,
      messages: const [ThreadStackStatusReceived(true)],
    );

    await _tapVisible(tester, find.text('Stop Thread'));
    await tester.pump();

    expect(repository.actions, contains('thread.disable'));
  });

  testWidgets('Start Border Router sends thread.br_init', (tester) async {
    final repository = _RecordingThreadRepository();
    await _pumpThreadScreen(
      tester,
      repository: repository,
      messages: const [ThreadStackStatusReceived(true)],
    );

    await _tapVisible(tester, find.text('Start Border Router'));
    await tester.pump();

    expect(repository.actions, contains('thread.br_init'));
  });

  testWidgets('Stop Border Router sends thread.br_deinit', (tester) async {
    final repository = _RecordingThreadRepository();
    await _pumpThreadScreen(tester, repository: repository);

    await _tapVisible(tester, find.text('Stop Border Router'));
    await tester.pump();

    expect(repository.actions, contains('thread.br_deinit'));
  });

  testWidgets('Refresh state uses existing refresh commands', (tester) async {
    final repository = _RecordingThreadRepository();
    await _pumpThreadScreen(tester, repository: repository);

    await _tapVisible(tester, find.text('Refresh Thread state'));
    await tester.pump();

    expect(repository.actions, [
      'thread.status_get',
      'thread.attached_get',
      'thread.role_get',
      'thread.active_dataset_get',
    ]);
  });

  testWidgets('raw diagnostics remain accessible in Advanced', (tester) async {
    await _pumpThreadScreen(tester);

    await _tapVisible(tester, find.text('Raw Thread command buttons'));
    await tester.pumpAndSettle();

    expect(find.text('Thread Commands'), findsOneWidget);
    expect(find.text('Refresh Unicast Addresses'), findsOneWidget);
    expect(find.text('Refresh Multicast Addresses'), findsOneWidget);
    expect(find.text('Refresh Active Dataset'), findsOneWidget);
  });
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

Future<void> _pumpThreadScreen(
  WidgetTester tester, {
  List<OrchestratorMessage> messages = const [],
  ThreadCommandRepository? repository,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        orchestratorMessageRepositoryProvider.overrideWithValue(
          _MessageRepo(messages),
        ),
        if (repository != null)
          threadCommandRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(home: Scaffold(body: ThreadScreen())),
    ),
  );
  await tester.pumpAndSettle();
}

final class _MessageRepo implements OrchestratorMessageRepository {
  final List<OrchestratorMessage> messages;

  const _MessageRepo(this.messages);

  @override
  Stream<OrchestratorMessage> watchMessages() => Stream.fromIterable(messages);
}

final class _RecordingThreadRepository implements ThreadCommandRepository {
  final List<String> actions = [];

  @override
  Future<Result<OrchestratorCommandResult>> enable() =>
      _record('thread.enable');

  @override
  Future<Result<OrchestratorCommandResult>> disable() =>
      _record('thread.disable');

  @override
  Future<Result<OrchestratorCommandResult>> refreshStatus() =>
      _record('thread.status_get');

  @override
  Future<Result<OrchestratorCommandResult>> refreshAttachment() =>
      _record('thread.attached_get');

  @override
  Future<Result<OrchestratorCommandResult>> refreshRole() =>
      _record('thread.role_get');

  @override
  Future<Result<OrchestratorCommandResult>> refreshActiveDataset() =>
      _record('thread.active_dataset_get');

  @override
  Future<Result<OrchestratorCommandResult>> refreshUnicastAddresses() =>
      _record('thread.unicast_addresses_get');

  @override
  Future<Result<OrchestratorCommandResult>> refreshMulticastAddresses() =>
      _record('thread.multicast_addresses_get');

  @override
  Future<Result<OrchestratorCommandResult>> initBorderRouter() =>
      _record('thread.br_init');

  @override
  Future<Result<OrchestratorCommandResult>> deinitBorderRouter() =>
      _record('thread.br_deinit');

  @override
  Future<Result<OrchestratorCommandResult>> initDataset(
    ThreadDatasetInitRequest request,
  ) => _record('thread.dataset.init');

  Future<Result<OrchestratorCommandResult>> _record(String action) async {
    actions.add(action);
    return Success(
      OrchestratorCommandResult(
        requestId: 'req-${actions.length}',
        action: action,
        ok: true,
        payload: const {},
      ),
    );
  }
}
