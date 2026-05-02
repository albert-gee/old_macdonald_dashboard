import 'package:dashboard/dashboard_app.dart';
import 'package:dashboard/service_locator.dart';
import 'package:dashboard/websocket/websocket_inbound_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
