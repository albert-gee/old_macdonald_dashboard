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

  test('ThreadCommandService encodes dataset init protocol', () async {
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

    final message = jsonDecode(websocket.sentMessage!) as Map<String, dynamic>;
    final payload = message['payload'] as Map<String, dynamic>;

    expect(message['type'], 'command');
    expect(message['action'], 'thread.dataset.init');
    expect(payload['master_key'], '00112233445566778899aabbccddeeff');
    expect(payload.containsKey('network_' 'key'), isFalse);
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
}
