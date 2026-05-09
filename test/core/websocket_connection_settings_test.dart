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
    final result = WebSocketConnectionSettings.fromInput(
      'ws://localhost/ws',
      rootCaAssetPath: rootCa,
    ) as Success<WebSocketConnectionSettings>;
    expect(result.value.rootCAAsset, isNull);
  });

  test('wss returns configured root CA', () {
    final result = WebSocketConnectionSettings.fromInput(
      'wss://localhost/ws',
      rootCaAssetPath: rootCa,
    ) as Success<WebSocketConnectionSettings>;
    expect(result.value.rootCAAsset, rootCa);
  });
}
