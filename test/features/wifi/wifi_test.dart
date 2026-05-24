import 'package:dashboard/src/core/errors/app_failure.dart';
import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/wifi/data/repositories/wifi_command_repository_impl.dart';
import 'package:dashboard/src/features/wifi/domain/entities/wifi_sta_credentials.dart';
import 'package:dashboard/src/features/wifi/presentation/controllers/wifi_sta_connect_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes.dart';

void main() {
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
}
