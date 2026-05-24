import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/core/websocket/websocket_connection_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const rootCa = 'assets/rootCA.pem';

  test('invalid scheme fails', () {
    final result = WebSocketConnectionSettings.fromInput(
      'http://example.com/ws',
      rootCaAssetPath: rootCa,
    );
    expect(result, isA<FailureResult<WebSocketConnectionSettings>>());
  });

  test('empty URL fails', () {
    final result = WebSocketConnectionSettings.fromInput(
      '',
      rootCaAssetPath: rootCa,
    );
    expect(result, isA<FailureResult<WebSocketConnectionSettings>>());
  });

  test('missing host fails', () {
    final result = WebSocketConnectionSettings.fromInput(
      'wss:///ws',
      rootCaAssetPath: rootCa,
    );
    expect(result, isA<FailureResult<WebSocketConnectionSettings>>());
  });

  test('ws returns null root CA', () {
    final result =
        WebSocketConnectionSettings.fromInput(
              'ws://localhost/ws',
              rootCaAssetPath: rootCa,
            )
            as Success<WebSocketConnectionSettings>;
    expect(result.value.rootCAAsset, isNull);
  });

  test('wss returns configured root CA', () {
    final result =
        WebSocketConnectionSettings.fromInput(
              'wss://localhost/ws',
              rootCaAssetPath: rootCa,
            )
            as Success<WebSocketConnectionSettings>;
    expect(result.value.rootCAAsset, rootCa);
  });

  test('wss without root CA is valid for fingerprint trust', () {
    final result =
        WebSocketConnectionSettings.fromInput(
              'wss://192.168.4.1/ws',
              trustedFingerprint:
                  'aabbccddeeff00112233445566778899aabbccddeeff00112233445566778899',
            )
            as Success<WebSocketConnectionSettings>;
    expect(result.value.rootCAAsset, isNull);
    expect(result.value.secure, isTrue);
    expect(result.value.host, '192.168.4.1');
    expect(result.value.trustedFingerprint, isNotNull);
  });
}
