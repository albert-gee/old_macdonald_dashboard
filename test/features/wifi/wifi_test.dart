import 'package:dashboard/src/core/errors/app_failure.dart';
import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/app/providers.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_command_result.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_message.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_snapshot.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_message_repository.dart';
import 'package:dashboard/src/features/wifi/data/repositories/wifi_command_repository_impl.dart';
import 'package:dashboard/src/features/wifi/domain/entities/wifi_network_readiness.dart';
import 'package:dashboard/src/features/wifi/domain/entities/wifi_sta_credentials.dart';
import 'package:dashboard/src/features/wifi/domain/repositories/wifi_command_repository.dart';
import 'package:dashboard/src/features/wifi/presentation/controllers/wifi_sta_connect_controller.dart';
import 'package:dashboard/src/features/wifi/presentation/screens/wifi_network_screen.dart';
import 'package:dashboard/src/features/wifi/presentation/widgets/wifi_network_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes.dart';

void main() {
  test(
    'Wi-Fi readiness derives unavailable when no snapshot or connection',
    () {
      final readiness = WifiNetworkReadiness.derive(
        connected: false,
        hasSnapshot: false,
      );

      expect(readiness.state, WifiReadinessState.unavailable);
    },
  );

  test(
    'Wi-Fi readiness derives offline when AP stopped and STA disconnected',
    () {
      final readiness = WifiNetworkReadiness.derive(
        connected: true,
        hasSnapshot: true,
        apRunning: false,
        staConfigured: false,
        staConnected: false,
      );

      expect(readiness.state, WifiReadinessState.offline);
    },
  );

  test(
    'Wi-Fi readiness derives localOnly when AP running and STA disconnected',
    () {
      final readiness = WifiNetworkReadiness.derive(
        connected: true,
        hasSnapshot: true,
        apRunning: true,
        staConfigured: false,
        staConnected: false,
      );

      expect(readiness.state, WifiReadinessState.localOnly);
    },
  );

  test('Wi-Fi readiness derives configured but disconnected', () {
    final readiness = WifiNetworkReadiness.derive(
      connected: true,
      hasSnapshot: true,
      apRunning: true,
      staConfigured: true,
      staConnected: false,
    );

    expect(readiness.state, WifiReadinessState.uplinkConfiguredButDisconnected);
  });

  test('Wi-Fi readiness derives uplinkConnected when STA has IP', () {
    final readiness = WifiNetworkReadiness.derive(
      connected: true,
      hasSnapshot: true,
      apRunning: true,
      staConfigured: true,
      staConnected: true,
      staIp: '192.168.1.25',
    );

    expect(readiness.state, WifiReadinessState.uplinkConnected);
  });

  test('RSSI maps to signal quality labels', () {
    expect(WifiSignalQuality.fromRssi(-45), WifiSignalQuality.excellent);
    expect(WifiSignalQuality.fromRssi(-60), WifiSignalQuality.good);
    expect(WifiSignalQuality.fromRssi(-70), WifiSignalQuality.weak);
    expect(WifiSignalQuality.fromRssi(-80), WifiSignalQuality.poor);
    expect(WifiSignalQuality.fromRssi(null), WifiSignalQuality.unknown);
  });

  test('command repository encodes wifi.sta_connect', () async {
    final client = RecordingCommandClient();
    final repository = WifiCommandRepositoryImpl(client: client);

    await repository.connectSta(
      const WifiStaCredentials(ssid: 'ssid', password: 'password'),
    );

    expect(client.commands.single.action, 'wifi.sta_connect');
    expect(client.commands.single.payload, {
      'ssid': 'ssid',
      'password': 'password',
    });
  });

  test('connect controller success', () async {
    final controller = WifiStaConnectController(
      repository: WifiCommandRepositoryImpl(client: RecordingCommandClient()),
    );
    await controller.connect(
      const WifiStaCredentials(ssid: 'ssid', password: 'password'),
    );
    expect(controller.state.success, isTrue);
  });

  test('connect controller disconnected failure', () async {
    final client = RecordingCommandClient()
      ..nextResult = const FailureResult(WebSocketDisconnectedFailure());
    final controller = WifiStaConnectController(
      repository: WifiCommandRepositoryImpl(client: client),
    );
    await controller.connect(
      const WifiStaCredentials(ssid: 'ssid', password: 'password'),
    );
    expect(controller.state.message, 'WebSocket is not connected.');
  });

  testWidgets('Wi-Fi Network page renders readiness card', (tester) async {
    await _pumpWifiScreen(tester);

    expect(find.text('Wi-Fi Network readiness'), findsOneWidget);
  });

  testWidgets('Local Dashboard access shows AP and default address', (
    tester,
  ) async {
    await _pumpWifiScreen(
      tester,
      snapshot: _snapshot(wifi: const WifiRuntimeSnapshot(apRunning: true)),
    );

    expect(find.text('Local Dashboard access'), findsOneWidget);
    expect(find.text('Running'), findsOneWidget);
    expect(find.text('192.168.4.1'), findsOneWidget);
  });

  testWidgets('Uplink Wi-Fi card shows connected IP', (tester) async {
    await _pumpWifiScreen(
      tester,
      snapshot: _snapshot(
        wifi: const WifiRuntimeSnapshot(
          apRunning: true,
          staConfigured: true,
          staConnected: true,
          staIp: '192.168.1.25',
          rssi: -52,
        ),
      ),
    );

    expect(find.text('Uplink Wi-Fi'), findsOneWidget);
    expect(find.text('192.168.1.25'), findsOneWidget);
    expect(find.text('Excellent'), findsOneWidget);
  });

  testWidgets('Uplink disconnected explains local AP fallback', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WifiUplinkCard(
            wifi: WifiRuntimeSnapshot(
              apRunning: true,
              staConfigured: true,
              staConnected: false,
            ),
            signalQuality: WifiSignalQuality.unknown,
          ),
        ),
      ),
    );

    expect(
      find.text(
        'Local chamber control can still work through the Orchestrator access point when uplink Wi-Fi is unavailable.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Password is not displayed after successful submit', (
    tester,
  ) async {
    final repository = _RecordingWifiRepository();
    await _pumpWifiScreen(tester, repository: repository);

    await tester.enterText(find.byType(TextFormField).first, 'FarmNet');
    await tester.enterText(find.byType(TextFormField).last, 'secret-password');
    await _tapVisible(tester, find.text('Connect uplink Wi-Fi'));
    await tester.pump();
    await tester.pump();

    final passwordEditor = tester.widget<EditableText>(
      find.byType(EditableText).last,
    );
    expect(passwordEditor.controller.text, isEmpty);
    expect(find.text('secret-password'), findsNothing);
  });

  testWidgets('wifi.sta_connect sends SSID/password from form', (tester) async {
    final repository = _RecordingWifiRepository();
    await _pumpWifiScreen(tester, repository: repository);

    await tester.enterText(find.byType(TextFormField).first, 'FarmNet');
    await tester.enterText(find.byType(TextFormField).last, 'secret-password');
    await _tapVisible(tester, find.text('Connect uplink Wi-Fi'));
    await tester.pump();

    expect(repository.credentials.single.ssid, 'FarmNet');
    expect(repository.credentials.single.password, 'secret-password');
  });

  testWidgets('Normal page does not look like raw snapshot dump', (
    tester,
  ) async {
    await _pumpWifiScreen(tester, snapshot: _snapshot());

    expect(find.text('Wi-Fi Runtime'), findsNothing);
    expect(find.textContaining('AP running:'), findsNothing);
    expect(find.textContaining('STA connected:'), findsNothing);
  });

  testWidgets('Advanced diagnostics is collapsed by default', (tester) async {
    await _pumpWifiScreen(tester, snapshot: _snapshot());

    expect(find.text('Advanced diagnostics'), findsOneWidget);
    expect(find.textContaining('ap_running:'), findsNothing);
  });

  testWidgets('Raw fields are visible only in Advanced diagnostics', (
    tester,
  ) async {
    await _pumpWifiScreen(
      tester,
      snapshot: _snapshot(
        wifi: const WifiRuntimeSnapshot(
          mode: 'apsta',
          apRunning: true,
          staConfigured: true,
          staConnected: true,
          staIp: '192.168.1.25',
          rssi: -61,
        ),
        websocket: const WebSocketRuntimeSnapshot(clients: 2),
      ),
    );

    expect(find.textContaining('ap_running:'), findsNothing);
    await _tapVisible(
      tester,
      find.text('For network troubleshooting and development.'),
    );
    await tester.pumpAndSettle();

    expect(find.text('mode: apsta'), findsOneWidget);
    expect(find.text('ap_running: true'), findsOneWidget);
    expect(find.text('sta_connected: true'), findsOneWidget);
    expect(find.text('websocket.clients: 2'), findsOneWidget);
  });
}

Future<void> _pumpWifiScreen(
  WidgetTester tester, {
  OrchestratorSnapshot? snapshot,
  WifiCommandRepository? repository,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        orchestratorMessageRepositoryProvider.overrideWithValue(
          _MessageRepo(
            snapshot == null ? const [] : [StateSnapshotReceived(snapshot)],
          ),
        ),
        if (repository != null)
          wifiCommandRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(home: Scaffold(body: WifiNetworkScreen())),
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
  WifiRuntimeSnapshot wifi = const WifiRuntimeSnapshot(
    apRunning: true,
    staConfigured: false,
    staConnected: false,
  ),
  WebSocketRuntimeSnapshot websocket = const WebSocketRuntimeSnapshot(),
}) {
  return OrchestratorSnapshot(
    wifi: wifi,
    thread: const ThreadRuntimeSnapshot(),
    matter: const MatterRuntimeSnapshot(),
    websocket: websocket,
  );
}

final class _MessageRepo implements OrchestratorMessageRepository {
  final List<OrchestratorMessage> messages;

  const _MessageRepo(this.messages);

  @override
  Stream<OrchestratorMessage> watchMessages() => Stream.fromIterable(messages);
}

final class _RecordingWifiRepository implements WifiCommandRepository {
  final List<WifiStaCredentials> credentials = [];

  @override
  Future<Result<OrchestratorCommandResult>> connectSta(
    WifiStaCredentials credentials,
  ) async {
    this.credentials.add(credentials);
    return Success(
      OrchestratorCommandResult(
        requestId: 'req-${this.credentials.length}',
        action: 'wifi.sta_connect',
        ok: true,
        payload: const {},
      ),
    );
  }
}
