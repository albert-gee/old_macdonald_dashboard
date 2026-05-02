import 'dart:async';
import 'dart:convert';

import 'package:dashboard/src/app/dashboard_app.dart';
import 'package:dashboard/services/i_matter_command_service.dart';
import 'package:dashboard/services/i_orchestrator_url_storage.dart';
import 'package:dashboard/services/i_thread_command_service.dart';
import 'package:dashboard/services/i_wifi_command_service.dart';
import 'package:dashboard/services/thread_command_service.dart';
import 'package:dashboard/src/core/config/app_dependencies.dart';
import 'package:dashboard/src/core/config/app_config.dart';
import 'package:dashboard/websocket/i_websocket_client.dart';
import 'package:dashboard/websocket/websocket_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeWebSocketClient implements IWebSocketClient {
  String? sentMessage;

  @override
  bool get isConnecting => false;

  @override
  bool get isConnected => true;

  @override
  Stream<String> get messages => const Stream.empty();

  @override
  Future<bool> connect({
    required String url,
    String? rootCAAsset,
    bool enableCompression = true,
    Duration pingInterval = const Duration(seconds: 10),
  }) async =>
      true;

  @override
  Future<bool> sendMessage(String message) async {
    sentMessage = message;
    return true;
  }

  @override
  Future<void> disconnect({
    int code = 1000,
    String reason = 'Client disconnect',
  }) async {}

  @override
  StreamSubscription<String> listen({
    required void Function(String message) onMessage,
    required void Function() onDone,
    required void Function(Object error) onError,
  }) =>
      const Stream<String>.empty().listen(onMessage);

  @override
  int? get closeCode => null;

  @override
  String? get closeReason => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AppConfig.local exposes local defaults', () {
    const config = AppConfig.local();

    expect(config.appTitle, 'Old MacDonald');
    expect(config.appSubtitle, 'Controlled Environment');
    expect(config.defaultWebSocketUrl, 'wss://192.168.4.1/ws');
    expect(config.rootCaAssetPath, 'assets/rootCA.pem');
  });

  test('AppDependencies.create builds shared WebSocket-backed services', () {
    final dependencies = AppDependencies.create();

    expect(dependencies.webSocketClient, isA<WebSocketClient>());
    expect(dependencies.orchestratorUrlStorage, isA<IOrchestratorUrlStorage>());
    expect(dependencies.threadCommandService, isA<IThreadCommandService>());
    expect(dependencies.wifiCommandService, isA<IWifiCommandService>());
    expect(dependencies.matterCommandService, isA<IMatterCommandService>());
  });

  group('ThreadCommandService protocol', () {
    test('encodes all no-payload Thread command actions', () async {
      await _expectThreadCommand(
        expectedAction: 'thread.enable',
        send: (service) => service.sendThreadEnableCommand(),
      );
      await _expectThreadCommand(
        expectedAction: 'thread.disable',
        send: (service) => service.sendThreadDisableCommand(),
      );
      await _expectThreadCommand(
        expectedAction: 'thread.status_get',
        send: (service) => service.sendThreadStatusGetCommand(),
      );
      await _expectThreadCommand(
        expectedAction: 'thread.attached_get',
        send: (service) => service.sendThreadAttachedGetCommand(),
      );
      await _expectThreadCommand(
        expectedAction: 'thread.role_get',
        send: (service) => service.sendThreadRoleGetCommand(),
      );
      await _expectThreadCommand(
        expectedAction: 'thread.active_dataset_get',
        send: (service) => service.sendThreadActiveDatasetGetCommand(),
      );
      await _expectThreadCommand(
        expectedAction: 'thread.unicast_addresses_get',
        send: (service) => service.sendThreadUnicastAddressesGetCommand(),
      );
      await _expectThreadCommand(
        expectedAction: 'thread.multicast_addresses_get',
        send: (service) => service.sendThreadMulticastAddressesGetCommand(),
      );
      await _expectThreadCommand(
        expectedAction: 'thread.br_init',
        send: (service) => service.sendThreadBorderRouterInitCommand(),
      );
      await _expectThreadCommand(
        expectedAction: 'thread.br_deinit',
        send: (service) => service.sendThreadBorderRouterDeinitCommand(),
      );
    });

    test('encodes dataset init protocol', () async {
      final client = FakeWebSocketClient();
      final service = ThreadCommandService(websocket: client);

      await service.sendThreadDatasetInitCommand(
        channel: 15,
        panId: 4660,
        networkName: 'OldMacdonald',
        extendedPanId: '0011223344556677',
        meshLocalPrefix: 'fd00::/64',
        networkKey: '00112233445566778899aabbccddeeff',
        pskc: 'ffeeddccbbaa99887766554433221100',
      );

      final message = jsonDecode(client.sentMessage!) as Map<String, dynamic>;
      final payload = message['payload'] as Map<String, dynamic>;

      expect(message['type'], 'command');
      expect(message['action'], 'thread.dataset.init');
      expect(payload['master_key'], '00112233445566778899aabbccddeeff');
      expect(payload.containsKey('network_key'), isFalse);
    });
  });

  testWidgets('DashboardApp smoke test', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final dependencies = AppDependencies.create();

    await tester.pumpWidget(
      DashboardApp(
        config: const AppConfig.local(),
        dependencies: dependencies,
      ),
    );
    await tester.pump();

    expect(find.text('Old MacDonald'), findsOneWidget);
    expect(find.text('Orchestrator'), findsWidgets);
  });

  testWidgets('ThreadPage smoke test', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final dependencies = AppDependencies.create();

    await tester.pumpWidget(
      DashboardApp(
        config: const AppConfig.local(),
        dependencies: dependencies,
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Thread Network'));
    await tester.pumpAndSettle();

    expect(find.text('Thread Status'), findsOneWidget);
    expect(find.text('Active Dataset'), findsOneWidget);
    expect(find.text('IP Addresses'), findsOneWidget);
    expect(find.text('Enable Thread'), findsOneWidget);
    expect(find.text('Disable Thread'), findsOneWidget);
    expect(find.text('Refresh Status'), findsOneWidget);
    expect(find.text('Init Border Router'), findsOneWidget);
    expect(find.text('Thread Dataset'), findsOneWidget);
  });
}

Future<void> _expectThreadCommand({
  required String expectedAction,
  required Future<void> Function(ThreadCommandService service) send,
}) async {
  final client = FakeWebSocketClient();
  final service = ThreadCommandService(websocket: client);

  await send(service);

  final message = jsonDecode(client.sentMessage!) as Map<String, dynamic>;
  expect(message['type'], 'command');
  expect(message['action'], expectedAction);
  expect(message.containsKey('payload'), isFalse);
}
