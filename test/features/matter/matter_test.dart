import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/features/devices/domain/entities/device_record.dart';
import 'package:dashboard/src/features/devices/domain/repositories/device_repository.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_readiness.dart';
import 'package:dashboard/src/features/matter/data/datasources/matter_cluster_asset_data_source.dart';
import 'package:dashboard/src/features/matter/data/repositories/matter_command_repository_impl.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_attribute_read_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_attribute_report.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_attribute_subscribe_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_cluster_command_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_controller_init_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_pair_ble_thread_request.dart';
import 'package:dashboard/src/features/matter/presentation/screens/matter_screen.dart';
import 'package:dashboard/src/features/matter/presentation/controllers/matter_event_controller.dart';
import 'package:dashboard/src/features/matter/presentation/controllers/matter_event_state.dart';
import 'package:dashboard/src/features/matter/presentation/widgets/matter_controller_init_form.dart';
import 'package:dashboard/src/features/matter/presentation/widgets/matter_network_cards.dart';
import 'package:dashboard/src/features/matter/presentation/widgets/matter_pair_ble_thread_form.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_message.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_snapshot.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_message_repository.dart';
import 'package:dashboard/src/features/thread/domain/entities/thread_readiness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Matter readiness derives unavailable without snapshot or connection',
    () {
      final readiness = MatterReadiness.derive(
        connected: false,
        hasSnapshot: false,
        threadReadiness: ThreadReadiness.derive(
          connected: false,
          hasThreadData: false,
        ),
      );

      expect(readiness.state, MatterReadinessState.unavailable);
    },
  );

  test('Matter readiness derives threadNotReady when Thread is not ready', () {
    final readiness = MatterReadiness.derive(
      connected: true,
      hasSnapshot: true,
      threadReadiness: ThreadReadiness.derive(
        connected: true,
        hasThreadData: true,
        enabled: false,
        datasetPresent: false,
        attached: false,
      ),
      controllerInitialized: true,
      commissionedNodeCount: 0,
    );

    expect(readiness.state, MatterReadinessState.threadNotReady);
  });

  test('Matter readiness derives controllerNotInitialized', () {
    final readiness = MatterReadiness.derive(
      connected: true,
      hasSnapshot: true,
      threadReadiness: _readyThread(),
      controllerInitialized: false,
      commissionedNodeCount: 0,
    );

    expect(readiness.state, MatterReadinessState.controllerNotInitialized);
  });

  test('Matter readiness derives readyToCommission', () {
    final readiness = MatterReadiness.derive(
      connected: true,
      hasSnapshot: true,
      threadReadiness: _readyThread(),
      controllerInitialized: true,
      commissionedNodeCount: 0,
    );

    expect(readiness.state, MatterReadinessState.readyToCommission);
  });

  test('Matter readiness derives devicesCommissioned', () {
    final readiness = MatterReadiness.derive(
      connected: true,
      hasSnapshot: true,
      threadReadiness: _readyThread(),
      controllerInitialized: true,
      commissionedNodeCount: 1,
    );

    expect(readiness.state, MatterReadinessState.devicesCommissioned);
  });

  test('cluster asset data source parses XML clusters', () async {
    final result = await MatterClusterAssetDataSource().loadClusters();
    expect(result, isA<Success>());
    final clusters = (result as Success).value as List;
    expect(clusters, isNotEmpty);
  });

  test('command repository encodes all Matter commands', () async {
    final client = RecordingCommandClient();
    final repository = MatterCommandRepositoryImpl(client: client);

    await repository.initializeController(
      const MatterControllerInitRequest(
        nodeId: '1',
        fabricId: 2,
        listenPort: 5540,
      ),
    );
    await repository.pairBleThread(
      const MatterPairBleThreadRequest(
        nodeId: '1',
        setupCode: '20202021',
        discriminator: '3840',
      ),
    );
    await repository.invokeClusterCommand(
      const MatterClusterCommandRequest(
        destinationId: '1',
        endpointId: 1,
        clusterId: 6,
        commandId: 1,
        commandData: '{}',
      ),
    );
    await repository.readAttribute(
      const MatterAttributeReadRequest(
        nodeId: '1',
        endpointId: 1,
        clusterId: 6,
        attributeId: 0,
      ),
    );
    await repository.subscribeAttribute(
      const MatterAttributeSubscribeRequest(
        nodeId: '1',
        endpointId: 1,
        clusterId: 6,
        attributeId: 0,
        minInterval: 1,
        maxInterval: 60,
      ),
    );

    expect(client.commands.map((command) => command.action), [
      'matter.controller_init',
      'matter.pair_ble_thread',
      'matter.cluster_command_invoke',
      'matter.attribute_read',
      'matter.attribute_subscribe',
    ]);
    expect(client.commands.first.payload, {
      'node_id': '1',
      'fabric_id': 2,
      'listen_port': 5540,
    });
  });

  test('matter event controller updates on events', () async {
    final controller = MatterEventController(
      messages: Stream<OrchestratorMessage>.fromIterable([
        const MatterCommissioningCompleteReceived(nodeId: 1, fabricIndex: 2),
        const MatterAttributeReportReceived(
          MatterAttributeReport(
            nodeId: 1,
            endpointId: 1,
            clusterId: 6,
            attributeId: 0,
            value: 'true',
          ),
        ),
        const MatterSubscribeDoneReceived(nodeId: 1, subscriptionId: 7),
      ]),
    );
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.recentEvents, hasLength(3));
  });

  testWidgets('Matter page renders readiness card', (tester) async {
    await _pumpMatterScreen(tester);

    expect(find.text('Matter Device Network readiness'), findsOneWidget);
  });

  testWidgets('Matter page explains chamber sensors and actuators', (
    tester,
  ) async {
    await _pumpMatterScreen(tester);

    expect(
      find.text(
        'Matter is used to commission and manage chamber sensors and actuators.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('primary pairing section is Pair chamber device', (tester) async {
    await _pumpMatterScreen(tester);

    expect(find.text('Pair chamber device'), findsWidgets);
    expect(find.text('Pair BLE Thread'), findsNothing);
  });

  testWidgets('pairing warns when Thread is not ready', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: MatterPairChamberDeviceCard(
              readiness: MatterReadiness.derive(
                connected: true,
                hasSnapshot: true,
                threadReadiness: ThreadReadiness.derive(
                  connected: true,
                  hasThreadData: true,
                  enabled: false,
                  datasetPresent: false,
                  attached: false,
                ),
                controllerInitialized: true,
                commissionedNodeCount: 0,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.text(
        'Complete Thread setup before pairing Matter-over-Thread devices.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('pairing warns when controller is not initialized', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MatterPairChamberDeviceCard(
                readiness: MatterReadiness.derive(
                  connected: true,
                  hasSnapshot: true,
                  threadReadiness: _readyThread(),
                  controllerInitialized: false,
                  commissionedNodeCount: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.text('Initialize the Matter controller before pairing devices.'),
      findsOneWidget,
    );
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Pair chamber device'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('Controller setup is not a raw primary page section', (
    tester,
  ) async {
    await _pumpMatterScreen(tester);

    expect(find.text('Controller Init'), findsNothing);
    expect(find.text('Fabric ID'), findsNothing);
    expect(find.text('Listen port'), findsNothing);
  });

  testWidgets('Commissioned devices section shows empty state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MatterCommissionedDevicesCard(nodes: [], registryDevices: []),
        ),
      ),
    );

    expect(
      find.text('No commissioned Matter devices reported yet.'),
      findsOneWidget,
    );
  });

  testWidgets('Commissioned devices section shows node label and node ID', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MatterCommissionedDevicesCard(
            nodes: [
              CommissionedMatterNodeSnapshot(
                nodeId: '123',
                label: 'Commissioned device label',
              ),
            ],
            registryDevices: [],
          ),
        ),
      ),
    );

    expect(find.text('Commissioned device label'), findsOneWidget);
    expect(find.text('Node ID: 123'), findsOneWidget);
  });

  testWidgets('Registry mapping status handles no registry devices', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MatterRegistryMappingCard(
            nodes: [CommissionedMatterNodeSnapshot(nodeId: '123')],
            registryDevices: [],
          ),
        ),
      ),
    );

    expect(find.text('Unmapped nodes'), findsOneWidget);
    expect(
      find.text(
        'Pairing is not the final step. Add or verify device capabilities before using this device in Chamber controls.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Registry mapping status handles mapped registry devices', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MatterCommissionedDevicesCard(
            nodes: [CommissionedMatterNodeSnapshot(nodeId: '123')],
            registryDevices: [
              DeviceRecord(
                deviceId: 'device-1',
                nodeId: '123',
                label: 'Device',
                reachable: true,
                capabilities: [
                  DeviceCapability(
                    capabilityId: 'cap-1',
                    semanticType: DeviceCapabilitySemanticType.relay,
                    label: 'Relay',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Mapped to device registry.'), findsOneWidget);
    expect(find.text('Capabilities: 1'), findsOneWidget);
  });

  testWidgets('MatterScreen refreshes registry and renders refreshed mapping', (
    tester,
  ) async {
    final repository = _DeviceRepo([
      const DeviceRecord(
        deviceId: 'device-1',
        nodeId: '123',
        label: 'Device',
        reachable: true,
        capabilities: [
          DeviceCapability(
            capabilityId: 'cap-1',
            semanticType: DeviceCapabilitySemanticType.relay,
            label: 'Relay',
          ),
        ],
      ),
    ]);

    await _pumpMatterScreen(
      tester,
      snapshot: _snapshot(
        matter: const MatterRuntimeSnapshot(
          controllerInitialized: true,
          commissionedNodes: [CommissionedMatterNodeSnapshot(nodeId: '123')],
        ),
      ),
      deviceRepository: repository,
    );

    expect(repository.listCalls, 1);
    expect(find.text('Mapped to device registry.'), findsOneWidget);
    expect(find.text('Capabilities: 1'), findsOneWidget);
  });

  testWidgets('Recent Matter activity renders readable labels', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MatterRecentActivityCard(
            events: [
              MatterCommissioningCompleteEvent(nodeId: 1, fabricIndex: 1),
              MatterSubscribeDoneEvent(nodeId: 1, subscriptionId: 7),
            ],
            runtimeEvents: [],
          ),
        ),
      ),
    );

    expect(find.text('Device commissioning completed'), findsOneWidget);
    expect(find.text('Subscription established'), findsOneWidget);
  });

  testWidgets('Advanced diagnostics is collapsed by default', (tester) async {
    await _pumpMatterScreen(tester);

    expect(find.text('Advanced diagnostics'), findsOneWidget);
    expect(find.text('Pair BLE Thread'), findsNothing);
    expect(find.textContaining('Cluster'), findsNothing);
  });

  testWidgets('Raw low-level Matter wording is only in Advanced', (
    tester,
  ) async {
    await _pumpMatterScreen(tester);

    await _tapVisible(
      tester,
      find.text('For low-level Matter setup and troubleshooting.'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Raw pairing command: Pair BLE Thread.'), findsOneWidget);
    expect(find.textContaining('Cluster'), findsOneWidget);
  });

  testWidgets('Matter controller init form still sends command', (
    tester,
  ) async {
    final client = RecordingCommandClient();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          matterCommandRepositoryProvider.overrideWithValue(
            MatterCommandRepositoryImpl(client: client),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: MatterControllerInitForm()),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), '1');
    await tester.enterText(find.byType(TextFormField).at(1), '2');
    await tester.enterText(find.byType(TextFormField).at(2), '5540');
    await tester.tap(find.text('Initialize Controller'));
    await tester.pump();

    expect(client.commands.single.action, 'matter.controller_init');
  });

  testWidgets('Matter pairing form still sends pair BLE Thread command', (
    tester,
  ) async {
    final client = RecordingCommandClient();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          matterCommandRepositoryProvider.overrideWithValue(
            MatterCommandRepositoryImpl(client: client),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: MatterPairBleThreadForm(submitLabel: 'Pair chamber device'),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), '1');
    await tester.enterText(find.byType(TextFormField).at(1), '20202021');
    await tester.enterText(find.byType(TextFormField).at(2), '3840');
    await tester.tap(find.text('Pair chamber device'));
    await tester.pump();

    expect(client.commands.single.action, 'matter.pair_ble_thread');
  });
}

ThreadReadiness _readyThread() {
  return ThreadReadiness.derive(
    connected: true,
    hasThreadData: true,
    enabled: true,
    datasetPresent: true,
    attached: true,
  );
}

Future<void> _pumpMatterScreen(
  WidgetTester tester, {
  OrchestratorSnapshot? snapshot,
  DeviceRepository? deviceRepository,
}) async {
  final repository = deviceRepository ?? _DeviceRepo();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        orchestratorMessageRepositoryProvider.overrideWithValue(
          _MessageRepo(
            snapshot == null ? const [] : [StateSnapshotReceived(snapshot)],
          ),
        ),
        deviceRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(home: Scaffold(body: MatterScreen())),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

OrchestratorSnapshot _snapshot({
  ThreadRuntimeSnapshot thread = const ThreadRuntimeSnapshot(
    enabled: true,
    attached: true,
    role: 'leader',
    datasetPresent: true,
  ),
  MatterRuntimeSnapshot matter = const MatterRuntimeSnapshot(
    controllerInitialized: true,
  ),
}) {
  return OrchestratorSnapshot(
    wifi: const WifiRuntimeSnapshot(),
    thread: thread,
    matter: matter,
    websocket: const WebSocketRuntimeSnapshot(),
  );
}

final class _MessageRepo implements OrchestratorMessageRepository {
  final List<OrchestratorMessage> messages;

  const _MessageRepo(this.messages);

  @override
  Stream<OrchestratorMessage> watchMessages() => Stream.fromIterable(messages);
}

final class _DeviceRepo implements DeviceRepository {
  final List<DeviceRecord> devices;
  int listCalls = 0;

  _DeviceRepo([this.devices = const []]);

  @override
  Future<Result<List<DeviceRecord>>> listDevices() async {
    listCalls += 1;
    return Success(devices);
  }

  @override
  Future<Result<DeviceRecord>> getDevice(String deviceId) async {
    return Success(devices.firstWhere((device) => device.deviceId == deviceId));
  }

  @override
  Future<Result<void>> renameDevice(String deviceId, String label) async =>
      const Success(null);

  @override
  Future<Result<void>> removeDevice(String deviceId) async =>
      const Success(null);
}
