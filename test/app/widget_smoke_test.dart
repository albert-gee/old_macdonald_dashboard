import 'dart:io';

import 'package:dashboard/src/app/dashboard_app.dart';
import 'package:dashboard/src/app/dashboard_destination.dart';
import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/errors/app_failure.dart';
import 'package:dashboard/src/core/config/app_config.dart';
import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/core/widgets/app_metric_tile.dart';
import 'package:dashboard/src/core/widgets/app_status_card.dart';
import 'package:dashboard/src/features/chamber/domain/entities/chamber_status.dart';
import 'package:dashboard/src/features/chamber/domain/repositories/chamber_repository.dart';
import 'package:dashboard/src/features/chamber/presentation/controllers/chamber_state.dart';
import 'package:dashboard/src/features/chamber/presentation/screens/chamber_screen.dart';
import 'package:dashboard/src/features/developer/presentation/screens/developer_screen.dart';
import 'package:dashboard/src/features/diagnostics/presentation/screens/diagnostics_screen.dart';
import 'package:dashboard/src/features/devices/domain/entities/device_record.dart';
import 'package:dashboard/src/features/devices/domain/repositories/device_repository.dart';
import 'package:dashboard/src/features/devices/presentation/screens/devices_screen.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_attribute.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_cluster.dart';
import 'package:dashboard/src/features/matter/domain/repositories/matter_cluster_repository.dart';
import 'package:dashboard/src/features/orchestrator/presentation/screens/orchestrator_screen.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_message.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_snapshot.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_message_repository.dart';
import 'package:dashboard/src/features/orchestrator/presentation/controllers/orchestrator_connection_state.dart';
import 'package:dashboard/src/features/orchestrator/presentation/controllers/orchestrator_runtime_state.dart';
import 'package:dashboard/src/features/overview/domain/operator_runtime.dart';
import 'package:dashboard/src/features/matter/presentation/widgets/matter_controller_init_form.dart';
import 'package:dashboard/src/features/thread/presentation/widgets/thread_dataset_form.dart';
import 'package:dashboard/src/features/thread/presentation/screens/thread_screen.dart';
import 'package:dashboard/src/features/wifi/presentation/screens/wifi_network_screen.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes.dart';

void main() {
  const config = AppConfig(
    appTitle: 'Old MacDonald',
    appSubtitle: 'Controlled Environment',
    defaultWebSocketUrl: 'ws://localhost/ws',
    rootCaAssetPath: 'assets/rootCA.pem',
  );

  testWidgets('Wi-Fi form validation prevents empty SSID/password', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: WifiNetworkScreen())),
      ),
    );

    await tester.ensureVisible(find.text('Connect uplink Wi-Fi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Connect uplink Wi-Fi'));
    await tester.pump();

    expect(find.text('Network name / SSID is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
  });

  testWidgets('thread screen smoke test', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: ThreadScreen())),
      ),
    );
    expect(find.text('Thread Mesh Network readiness'), findsOneWidget);
    expect(find.text('Network state'), findsOneWidget);
    expect(find.text('Recommended action'), findsOneWidget);
  });

  testWidgets('dataset form validation prevents invalid fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: ThreadDatasetForm())),
      ),
    );

    await tester.tap(find.text('Initialize'));
    await tester.pump();

    expect(find.text('Channel is required.'), findsOneWidget);
    expect(find.text('PAN ID is required.'), findsOneWidget);
    expect(find.text('Network name is required.'), findsOneWidget);
  });

  testWidgets('matter controller validates unsigned node ID', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: MatterControllerInitForm())),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'abc');
    await tester.tap(find.text('Initialize Controller'));
    await tester.pump();

    expect(
      find.text('Node ID must be an unsigned decimal integer.'),
      findsOneWidget,
    );
  });

  testWidgets('operator shell navigation smoke test', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          matterClusterRepositoryProvider.overrideWithValue(_ClusterRepo()),
        ],
        child: const DashboardApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Old Macdonald'), findsWidgets);
    expect(find.text('Overview'), findsWidgets);
    expect(find.text('Connect'), findsOneWidget);
    expect(find.text('Next action'), findsOneWidget);

    await tester.tap(find.text('Setup').first);
    await tester.pumpAndSettle();
    expect(find.text('Step 1: Connect to Orchestrator'), findsOneWidget);
    expect(find.text('Step 2: Prepare Thread dataset'), findsOneWidget);

    await tester.tap(find.text('Devices').first);
    await tester.pumpAndSettle();
    expect(find.text('Registry overview'), findsOneWidget);

    await tester.tap(find.text('Diagnostics').first);
    await tester.pumpAndSettle();
    expect(find.text('Known hardware state'), findsOneWidget);
    expect(find.text('Protocol log'), findsOneWidget);
  });

  testWidgets('navigation uses destination keys and shows global connect', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          matterClusterRepositoryProvider.overrideWithValue(_ClusterRepo()),
        ],
        child: const DashboardApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Connect'), findsOneWidget);
    expect(find.text('Connect to Orchestrator'), findsWidgets);

    await tester.tap(find.text('Setup').first);
    await tester.pumpAndSettle();
    final scope = tester.element(find.byType(DashboardApp));
    final selected = ProviderScope.containerOf(
      scope,
    ).read(selectedDashboardDestinationProvider);
    expect(selected, DashboardDestinationKey.setup);
  });

  testWidgets('Overview shows Matter platform failure as next action', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          matterClusterRepositoryProvider.overrideWithValue(_ClusterRepo()),
          operatorRuntimeProvider.overrideWithValue(
            _operatorRuntime(
              snapshot: OrchestratorSnapshot.fromPayload({
                'thread': {'dataset_present': true, 'enabled': true},
                'matter': {
                  'platform_initialized': false,
                  'platform_error': 'MATTER_PLATFORM_INIT_FAILED:ESP_FAIL',
                },
              }),
            ),
          ),
        ],
        child: const DashboardApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Matter platform failed'), findsWidgets);
    expect(find.text('MATTER_PLATFORM_INIT_FAILED:ESP_FAIL'), findsWidgets);
  });

  testWidgets('Setup blocks commissioning when Matter platform failed', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          matterClusterRepositoryProvider.overrideWithValue(_ClusterRepo()),
          selectedDashboardDestinationProvider.overrideWith((_) {
            return DashboardDestinationKey.setup;
          }),
          operatorRuntimeProvider.overrideWithValue(
            _operatorRuntime(
              snapshot: OrchestratorSnapshot.fromPayload({
                'thread': {'dataset_present': true, 'enabled': true},
                'matter': {
                  'platform_initialized': false,
                  'platform_error': 'MATTER_PLATFORM_INIT_FAILED:ESP_FAIL',
                },
              }),
            ),
          ),
        ],
        child: const DashboardApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Matter platform did not initialize on the Orchestrator.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Commissioning is unavailable until Matter platform and controller prerequisites are healthy.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Setup default dataset uses CIDR mesh-local prefix', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final commandClient = RecordingCommandClient();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          matterClusterRepositoryProvider.overrideWithValue(_ClusterRepo()),
          orchestratorCommandClientProvider.overrideWithValue(commandClient),
          selectedDashboardDestinationProvider.overrideWith((_) {
            return DashboardDestinationKey.setup;
          }),
          operatorRuntimeProvider.overrideWithValue(
            _operatorRuntime(snapshot: OrchestratorSnapshot.fromPayload({})),
          ),
        ],
        child: const DashboardApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Development default uses fixed Thread credentials'),
      findsOneWidget,
    );
    final createDefaultDataset = find.text(
      'Create development default dataset',
    );
    await tester.ensureVisible(createDefaultDataset);
    await tester.pumpAndSettle();
    await tester.tap(createDefaultDataset);
    await tester.pumpAndSettle();

    final command = commandClient.commands.single;
    expect(command.action, 'thread.dataset.init');
    expect(command.payload['mesh_local_prefix'], 'fd11:22::/64');
  });

  testWidgets('Diagnostics shows hardware validation copy commands', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: DiagnosticsScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hardware validation commands'), findsOneWidget);
    expect(
      find.byTooltip('Copy hardware validation command sequence'),
      findsOneWidget,
    );
    expect(find.textContaining('wscat --ca assets/rootCA.pem'), findsOneWidget);
  });

  testWidgets('orchestrator page shows setup checklist before URL editor', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: OrchestratorScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('System Connection & Trust'), findsOneWidget);
    expect(find.text('Setup checklist'), findsOneWidget);
    expect(find.text('WebSocket URL editor'), findsOneWidget);
  });

  testWidgets(
    'devices page shows registry overview and onboarding empty state',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            deviceRepositoryProvider.overrideWithValue(_EmptyDeviceRepo()),
          ],
          child: const MaterialApp(home: Scaffold(body: DevicesScreen())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Registry overview'), findsOneWidget);
      expect(find.text('No chamber devices are registered.'), findsWidgets);
      expect(find.text('Go to Setup'), findsOneWidget);
    },
  );

  testWidgets('chamber does not render raw empty reading strings', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          deviceRepositoryProvider.overrideWithValue(_EmptyDeviceRepo()),
          chamberRepositoryProvider.overrideWithValue(_ChamberRepo()),
          orchestratorMessageRepositoryProvider.overrideWithValue(
            _MessageRepo(),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: ChamberScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Temperature: - C'), findsNothing);
    expect(find.text('Pressure: - kPa'), findsNothing);
    expect(find.text('No reading'), findsWidgets);
  });

  testWidgets('devices list shows product-first rows and hides technical IDs', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [deviceRepositoryProvider.overrideWithValue(_DeviceRepo())],
        child: const MaterialApp(home: Scaffold(body: DevicesScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Environmental sensor'), findsOneWidget);
    expect(find.text('Reachable'), findsWidgets);
    expect(find.text('Device ID: sensor-1\nNode ID: 123'), findsNothing);

    await tester.ensureVisible(find.text('Technical details').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Technical details').first);
    await tester.pumpAndSettle();
    expect(find.text('Device ID: sensor-1\nNode ID: 123'), findsOneWidget);
  });

  testWidgets('device remove requires confirmation', (tester) async {
    final repository = _DeviceRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [deviceRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: Scaffold(body: DevicesScreen())),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    expect(find.text('Remove device?'), findsOneWidget);
    expect(repository.removeCount, 0);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repository.removeCount, 0);

    await tester.ensureVisible(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove').last);
    await tester.pumpAndSettle();
    expect(repository.removeCount, 1);
  });

  testWidgets('orchestrator raw diagnostics are not primary content', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: OrchestratorScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Setup checklist'), findsOneWidget);
    expect(find.text('Pending Commands'), findsNothing);
    expect(find.text('Runtime Snapshot'), findsNothing);

    await tester.ensureVisible(find.text('Show Orchestrator diagnostics'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show Orchestrator diagnostics'));
    await tester.pumpAndSettle();
    expect(find.text('Pending Commands'), findsOneWidget);
    expect(find.text('Runtime Snapshot'), findsOneWidget);
  });

  testWidgets('developer screen contains raw Matter tools', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          matterClusterRepositoryProvider.overrideWithValue(_ClusterRepo()),
        ],
        child: const MaterialApp(home: Scaffold(body: DeveloperScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cluster Command'), findsOneWidget);
    expect(find.text('Read Attribute'), findsWidgets);
    expect(find.text('Subscribe Attribute'), findsWidgets);
    expect(
      find.text(
        'Developer tools bypass normal operator workflows. Use for diagnostics and recovery.',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'status and metric tiles support neutral warning and critical tones',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppStatusCard(
                  title: 'Neutral',
                  value: 'Unavailable',
                  active: false,
                ),
                AppStatusCard(
                  title: 'Critical',
                  value: 'Fault',
                  active: false,
                  tone: AppStatusTone.critical,
                ),
                AppMetricTile(
                  label: 'Warning metric',
                  value: 'Missing',
                  tone: AppMetricTone.warning,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Unavailable'), findsOneWidget);
      expect(find.text('Fault'), findsOneWidget);
      expect(find.text('Missing'), findsOneWidget);
    },
  );

  testWidgets('primary pages do not render AppStatusCard', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          matterClusterRepositoryProvider.overrideWithValue(_ClusterRepo()),
        ],
        child: const DashboardApp(),
      ),
    );
    await tester.pumpAndSettle();

    for (final label in [
      'Overview',
      'Setup',
      'Chamber',
      'Devices',
      'Diagnostics',
      'Developer Tools',
    ]) {
      await tester.tap(find.text(label).first);
      await tester.pumpAndSettle();
      expect(find.byType(AppStatusCard), findsNothing);
    }
  });

  test('no concrete example device names remain in Dashboard sources', () {
    final files = Directory.current
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (file) => file.path.endsWith('.dart') || file.path.endsWith('.md'),
        );
    final forbiddenTerms = [
      'BM'
          'P',
      'BM'
          'P280',
      'Mi'
          'st',
      'Root Chamber '
          'Temperature',
      'bm'
          'p280',
      'mi'
          'st',
      'BM'
          'P280-style',
    ];
    final forbidden = RegExp(forbiddenTerms.map(RegExp.escape).join('|'));
    for (final file in files) {
      final normalized = file.path.replaceAll('\\', '/');
      if (normalized.contains('/build/') ||
          normalized.contains('/.dart_tool/') ||
          normalized.endsWith('/test/app/widget_smoke_test.dart')) {
        continue;
      }
      expect(
        forbidden.hasMatch(file.readAsStringSync()),
        isFalse,
        reason: 'Concrete example name found in ${file.path}',
      );
    }
  });

  testWidgets('chamber screen uses capability selectors, not typed IDs', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          deviceRepositoryProvider.overrideWithValue(_DeviceRepo()),
          chamberRepositoryProvider.overrideWithValue(_ChamberRepo()),
          orchestratorMessageRepositoryProvider.overrideWithValue(
            _MessageRepo(),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: ChamberScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Environmental sensor - Temperature'), findsOneWidget);
    expect(find.text('Environmental sensor - Pressure'), findsOneWidget);
    expect(find.text('Switchable actuator - On/Off'), findsOneWidget);
    expect(find.text('Temperature device ID'), findsNothing);
    expect(find.text('Pressure device ID'), findsNothing);
    expect(find.text('Relay device ID'), findsNothing);
  });
}

final class _ClusterRepo implements MatterClusterRepository {
  @override
  Future<Result<List<MatterCluster>>> loadClusters() async {
    return const Success([
      MatterCluster(
        id: '0x0006',
        name: 'On/Off',
        attributes: [MatterAttribute(id: '0x0000', name: 'OnOff')],
      ),
    ]);
  }
}

final class _DeviceRepo implements DeviceRepository {
  int removeCount = 0;

  @override
  Future<Result<List<DeviceRecord>>> listDevices() async {
    return const Success([
      DeviceRecord(
        deviceId: 'sensor-1',
        nodeId: '123',
        label: 'Environmental sensor',
        reachable: true,
        capabilities: [
          DeviceCapability(
            capabilityId: 'capability-1',
            semanticType: DeviceCapabilitySemanticType.temperature,
            endpointId: 1,
            clusterId: 1026,
            attributeId: 0,
            label: 'Temperature',
          ),
          DeviceCapability(
            capabilityId: 'capability-2',
            semanticType: DeviceCapabilitySemanticType.pressure,
            endpointId: 2,
            clusterId: 1027,
            attributeId: 0,
            label: 'Pressure',
          ),
        ],
      ),
      DeviceRecord(
        deviceId: 'actuator-1',
        nodeId: '987',
        label: 'Switchable actuator',
        reachable: true,
        capabilities: [
          DeviceCapability(
            capabilityId: 'capability-3',
            semanticType: DeviceCapabilitySemanticType.relay,
            endpointId: 1,
            clusterId: 6,
            commandId: 1,
            label: 'On/Off',
          ),
        ],
      ),
    ]);
  }

  @override
  Future<Result<DeviceRecord>> getDevice(String deviceId) async {
    final result = await listDevices() as Success<List<DeviceRecord>>;
    return Success(
      result.value.firstWhere((device) => device.deviceId == deviceId),
    );
  }

  @override
  Future<Result<void>> renameDevice(String deviceId, String label) async =>
      const Success(null);

  @override
  Future<Result<void>> refreshDevice(String deviceId) async =>
      const Success(null);

  @override
  Future<Result<void>> removeDevice(String deviceId) async {
    removeCount += 1;
    return Future.value(const Success(null));
  }
}

final class _EmptyDeviceRepo implements DeviceRepository {
  @override
  Future<Result<List<DeviceRecord>>> listDevices() async => const Success([]);

  @override
  Future<Result<DeviceRecord>> getDevice(String deviceId) async =>
      const FailureResult(UnknownFailure('No device.'));

  @override
  Future<Result<void>> renameDevice(String deviceId, String label) async =>
      const Success(null);

  @override
  Future<Result<void>> refreshDevice(String deviceId) async =>
      const Success(null);

  @override
  Future<Result<void>> removeDevice(String deviceId) async =>
      const Success(null);
}

final class _ChamberRepo implements ChamberRepository {
  @override
  Future<Result<ChamberStatus>> getStatus() async =>
      const Success(ChamberStatus());

  @override
  Future<Result<SensorReadResult>> readPressure(
    String deviceId,
    String capabilityId,
  ) async => const Success(SensorReadResult(value: 101.3));

  @override
  Future<Result<SensorReadResult>> readTemperature(
    String deviceId,
    String capabilityId,
  ) async => const Success(SensorReadResult(value: 23.4));

  @override
  Future<Result<void>> setRelay(
    String deviceId,
    String capabilityId,
    bool on,
  ) async => const Success(null);

  @override
  Future<Result<ChamberControlRule>> saveTemperatureRule({
    required String sensorDeviceId,
    required String sensorCapabilityId,
    required String actuatorDeviceId,
    required String actuatorCapabilityId,
    required double minCelsius,
    required double maxCelsius,
    required bool enabled,
  }) async => Success(
    ChamberControlRule(
      configured: true,
      enabled: enabled,
      minCelsius: minCelsius,
      maxCelsius: maxCelsius,
      state: enabled ? 'idle' : 'disabled',
    ),
  );

  @override
  Future<Result<void>> setTemperatureControlEnabled(bool enabled) async =>
      const Success(null);
}

final class _MessageRepo implements OrchestratorMessageRepository {
  @override
  Stream<OrchestratorMessage> watchMessages() => const Stream.empty();
}

OperatorRuntime _operatorRuntime({required OrchestratorSnapshot snapshot}) {
  return OperatorRuntime(
    connection: const OrchestratorConnectionState(
      url: 'wss://192.168.4.1/ws',
      status: WebSocketConnectionStatus.connected,
    ),
    runtime: OrchestratorRuntimeState(
      snapshot: snapshot,
      lastSnapshotAt: DateTime(2026),
    ),
    devices: const [],
    chamber: const ChamberState(),
  );
}
