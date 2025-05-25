import 'dart:convert';
import 'package:dashboard/websocket/websocket_client.dart';
import 'i_wifi_command_service.dart';

class WifiCommandService implements IWifiCommandService {
  final WebSocketClient websocket;

  WifiCommandService({required this.websocket});

  @override
  Future<void> sendStaConnectCommand({required String ssid, required String password}) async {
    final message = jsonEncode({
      'type': 'command',
      'action': 'wifi.sta_connect',
      'payload': {
        'ssid': ssid,
        'password': password,
      },
    });

    await websocket.sendMessage(message);
  }
}
