import 'dart:convert';

import 'package:dashboard/dashboard_app.dart';
import 'package:dashboard/service_locator.dart';
import 'package:dashboard/services/thread_command_service.dart';
import 'package:dashboard/websocket/websocket_client.dart';
import 'package:dashboard/websocket/websocket_inbound_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeWebSocketClient extends WebSocketClient {
  String? sentMessage;

  @override
  Future<bool> sendMessage(String message) async {
    sentMessage = message;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WebSocketInboundMessage parser', () {
    test('parses thread stack status', () {
      final message = WebSocketInboundMessage.fromJson({
        'type': 'info',
        'action': 'thread.stack_status',
        'payload': {'running': true},
      });

      expect(message, isA<ThreadStackStatusMessage>());
      expect((message as ThreadStackStatusMessage).running, isTrue);
    });

    test('malformed payload does not crash and uses defaults', () {
      final message = WebSocketInboundMessage.fromJson({
        'type': 'info',
        'action': 'thread.stack_status',
        'payload': 'bad-payload',
      });

      expect(message, isA<ThreadStackStatusMessage>());
      expect((message as ThreadStackStatusMessage).running, isFalse);
    });

    test('unknown type and action returns generic message', () {
      final message = WebSocketInboundMessage.fromJson({
        'type': 'unknown',
        'action': 'unknown.action',
        'payload': {'value': 1},
      });

      expect(message, isA<GenericMessage>());
    });
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
      final websocket = FakeWebSocketClient();
      final service = ThreadCommandService(websocket: websocket);

      await service.sendThreadDatasetInitCommand(
        channel: 15,
        panId: 4660,
        networkName: 'OldMacdonald',
        extendedPanId: '0011223344556677',
        meshLocalPrefix: 'fd00::/64',
        networkKey: '00112233445566778899aabbccddeeff',
        pskc: 'ffeeddccbbaa99887766554433221100',
      );

      final message =
          jsonDecode(websocket.sentMessage!) as Map<String, dynamic>;
      final payload = message['payload'] as Map<String, dynamic>;

      expect(message['type'], 'command');
      expect(message['action'], 'thread.dataset.init');
      expect(payload['master_key'], '00112233445566778899aabbccddeeff');
      expect(payload.containsKey('network_' 'key'), isFalse);
    });
  });

  testWidgets('DashboardApp smoke test', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await getIt.reset();
    await setupServiceLocator();

    await tester.pumpWidget(
      const DashboardApp(
        title: 'Old MacDonald',
        subTitle: 'Controlled Environment',
      ),
    );
    await tester.pump();

    expect(find.text('Old MacDonald'), findsOneWidget);
    expect(find.text('Orchestrator'), findsWidgets);
  });

  testWidgets('ThreadPage smoke test', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await getIt.reset();
    await setupServiceLocator();

    await tester.pumpWidget(
      const DashboardApp(
        title: 'Old MacDonald',
        subTitle: 'Controlled Environment',
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
  final websocket = FakeWebSocketClient();
  final service = ThreadCommandService(websocket: websocket);

  await send(service);

  final message = jsonDecode(websocket.sentMessage!) as Map<String, dynamic>;
  expect(message['type'], 'command');
  expect(message['action'], expectedAction);
  expect(message.containsKey('payload'), isFalse);
}
