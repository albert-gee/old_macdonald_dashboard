import 'package:dashboard/src/core/websocket/websocket_connection_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const rootCaAssetPath = 'assets/rootCA.pem';

  test('empty input returns null', () {
    expect(
      WebSocketConnectionSettings.fromInput(
        '',
        rootCaAssetPath: rootCaAssetPath,
      ),
      isNull,
    );
  });

  test('http URL returns null', () {
    expect(
      WebSocketConnectionSettings.fromInput(
        'http://example.com',
        rootCaAssetPath: rootCaAssetPath,
      ),
      isNull,
    );
  });

  test('ws URL keeps URL and has no root CA asset', () {
    final settings = WebSocketConnectionSettings.fromInput(
      'ws://192.168.4.1/ws',
      rootCaAssetPath: rootCaAssetPath,
    );

    expect(settings, isNotNull);
    expect(settings!.url, 'ws://192.168.4.1/ws');
    expect(settings.rootCAAsset, isNull);
  });

  test('wss URL uses root CA asset', () {
    final settings = WebSocketConnectionSettings.fromInput(
      'wss://192.168.4.1/ws',
      rootCaAssetPath: rootCaAssetPath,
    );

    expect(settings, isNotNull);
    expect(settings!.url, 'wss://192.168.4.1/ws');
    expect(settings.rootCAAsset, rootCaAssetPath);
  });

  test('leading and trailing spaces are trimmed', () {
    final settings = WebSocketConnectionSettings.fromInput(
      '  ws://192.168.4.1/ws  ',
      rootCaAssetPath: rootCaAssetPath,
    );

    expect(settings, isNotNull);
    expect(settings!.url, 'ws://192.168.4.1/ws');
  });
}
