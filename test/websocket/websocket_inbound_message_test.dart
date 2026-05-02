import 'package:dashboard/websocket/websocket_inbound_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('thread.stack_status with running true returns status message', () {
    final message = WebSocketInboundMessage.fromJson({
      'type': 'info',
      'action': 'thread.stack_status',
      'payload': {'running': true},
    });

    expect(message, isA<ThreadStackStatusMessage>());
    expect((message as ThreadStackStatusMessage).running, isTrue);
  });

  test('malformed payload string does not crash and returns running false', () {
    final message = WebSocketInboundMessage.fromJson({
      'type': 'info',
      'action': 'thread.stack_status',
      'payload': 'bad-payload',
    });

    expect(message, isA<ThreadStackStatusMessage>());
    expect((message as ThreadStackStatusMessage).running, isFalse);
  });

  test('unknown type and action returns GenericMessage', () {
    final message = WebSocketInboundMessage.fromJson({
      'type': 'unknown',
      'action': 'unknown.action',
      'payload': {'value': 1},
    });

    expect(message, isA<GenericMessage>());
    expect(message.type, 'unknown');
    expect(message.action, 'unknown.action');
  });

  test('GenericMessage payload is normalized to a map', () {
    final stringPayloadMessage = WebSocketInboundMessage.fromJson({
      'type': 'unknown',
      'action': 'unknown.action',
      'payload': 'bad-payload',
    });
    final listPayloadMessage = WebSocketInboundMessage.fromJson({
      'type': 'unknown',
      'action': 'unknown.action',
      'payload': ['bad-payload'],
    });

    expect(stringPayloadMessage, isA<GenericMessage>());
    expect(stringPayloadMessage.payload, isA<Map<String, Object?>>());
    expect(stringPayloadMessage.payload, isEmpty);
    expect(listPayloadMessage, isA<GenericMessage>());
    expect(listPayloadMessage.payload, isA<Map<String, Object?>>());
    expect(listPayloadMessage.payload, isEmpty);
  });

  test('ipv6.unicast_addresses filters non-string values', () {
    final message = WebSocketInboundMessage.fromJson({
      'type': 'info',
      'action': 'ipv6.unicast_addresses',
      'payload': {
        'unicast': ['fd00::1', 1, null, 'fe80::1'],
      },
    });

    expect(message, isA<UnicastAddressListMessage>());
    expect(
      (message as UnicastAddressListMessage).addresses,
      ['fd00::1', 'fe80::1'],
    );
  });

  test('missing type returns GenericMessage with empty type', () {
    final message = WebSocketInboundMessage.fromJson({
      'action': 'unknown.action',
      'payload': {'value': 1},
    });

    expect(message, isA<GenericMessage>());
    expect(message.type, isEmpty);
    expect(message.payload, {'value': 1});
  });
}
