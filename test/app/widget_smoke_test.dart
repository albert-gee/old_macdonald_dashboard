import 'package:dashboard/src/app/dashboard_app.dart';
import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/core/config/app_config.dart';
import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/chamber/domain/entities/chamber_status.dart';
import 'package:dashboard/src/features/chamber/domain/repositories/chamber_repository.dart';
import 'package:dashboard/src/features/chamber/presentation/screens/chamber_screen.dart';
import 'package:dashboard/src/features/developer/presentation/screens/developer_screen.dart';
import 'package:dashboard/src/features/devices/domain/entities/device_record.dart';
import 'package:dashboard/src/features/devices/domain/repositories/device_repository.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_attribute.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_cluster.dart';
import 'package:dashboard/src/features/matter/domain/repositories/matter_cluster_repository.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_message.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_message_repository.dart';
import 'package:dashboard/src/features/matter/presentation/widgets/matter_controller_init_form.dart';
import 'package:dashboard/src/features/thread/presentation/widgets/thread_dataset_form.dart';
import 'package:dashboard/src/features/thread/presentation/screens/thread_screen.dart';
import 'package:dashboard/src/features/wifi/presentation/screens/wifi_sta_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        child: MaterialApp(home: Scaffold(body: WifiStaScreen())),
      ),
    );

    await tester.tap(find.text('Connect'));
    await tester.pump();

    expect(find.text('SSID is required.'), findsOneWidget);
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

  testWidgets('matter screen and dashboard navigation smoke test', (
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

    expect(find.text('Orchestrator'), findsWidgets);
    await tester.tap(find.text('Wi-Fi STA').first);
    await tester.pumpAndSettle();
    expect(find.text('Wi-Fi STA Connection'), findsOneWidget);

    await tester.tap(find.text('Thread Network').first);
    await tester.pumpAndSettle();
    expect(find.text('Thread Mesh Network readiness'), findsOneWidget);

    await tester.tap(find.text('Matter Network').first);
    await tester.pumpAndSettle();
    expect(find.text('Matter Network'), findsWidgets);
    expect(find.text('Controller Init'), findsOneWidget);
    expect(find.text('Pair BLE Thread'), findsWidgets);
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

    expect(find.text('BMP280 Sensor - Temperature'), findsOneWidget);
    expect(find.text('BMP280 Sensor - Pressure'), findsOneWidget);
    expect(find.text('Mist Relay - On/Off'), findsOneWidget);
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
  @override
  Future<Result<List<DeviceRecord>>> listDevices() async {
    return const Success([
      DeviceRecord(
        deviceId: 'bmp280-1',
        nodeId: '123',
        label: 'BMP280 Sensor',
        reachable: true,
        capabilities: [
          DeviceCapability(
            capabilityId: 'bmp280-1-temperature',
            semanticType: DeviceCapabilitySemanticType.temperature,
            endpointId: 1,
            clusterId: 1026,
            attributeId: 0,
            label: 'Temperature',
          ),
          DeviceCapability(
            capabilityId: 'bmp280-1-pressure',
            semanticType: DeviceCapabilitySemanticType.pressure,
            endpointId: 2,
            clusterId: 1027,
            attributeId: 0,
            label: 'Pressure',
          ),
        ],
      ),
      DeviceRecord(
        deviceId: 'relay-1',
        nodeId: '987',
        label: 'Mist Relay',
        reachable: true,
        capabilities: [
          DeviceCapability(
            capabilityId: 'relay-1-onoff',
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
  Future<Result<void>> removeDevice(String deviceId) async =>
      const Success(null);
}

final class _ChamberRepo implements ChamberRepository {
  @override
  Future<Result<ChamberStatus>> getStatus() async =>
      const Success(ChamberStatus());

  @override
  Future<Result<SensorReadResult>> readPressure(String deviceId) async =>
      const Success(SensorReadResult(value: 101.3));

  @override
  Future<Result<SensorReadResult>> readTemperature(String deviceId) async =>
      const Success(SensorReadResult(value: 23.4));

  @override
  Future<Result<void>> setRelay(String deviceId, bool on) async =>
      const Success(null);
}

final class _MessageRepo implements OrchestratorMessageRepository {
  @override
  Stream<OrchestratorMessage> watchMessages() => const Stream.empty();
}
