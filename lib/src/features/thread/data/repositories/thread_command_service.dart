import 'dart:convert';

import 'package:dashboard/websocket/i_websocket_client.dart';
import 'i_thread_command_service.dart';

class ThreadCommandService implements IThreadCommandService {
  final IWebSocketClient websocket;

  ThreadCommandService({required this.websocket});

  @override
  Future<void> sendThreadEnableCommand() => _sendCommand('thread.enable');

  @override
  Future<void> sendThreadDisableCommand() => _sendCommand('thread.disable');

  @override
  Future<void> sendThreadStatusGetCommand() =>
      _sendCommand('thread.status_get');

  @override
  Future<void> sendThreadAttachedGetCommand() =>
      _sendCommand('thread.attached_get');

  @override
  Future<void> sendThreadRoleGetCommand() => _sendCommand('thread.role_get');

  @override
  Future<void> sendThreadActiveDatasetGetCommand() =>
      _sendCommand('thread.active_dataset_get');

  @override
  Future<void> sendThreadUnicastAddressesGetCommand() =>
      _sendCommand('thread.unicast_addresses_get');

  @override
  Future<void> sendThreadMulticastAddressesGetCommand() =>
      _sendCommand('thread.multicast_addresses_get');

  @override
  Future<void> sendThreadBorderRouterInitCommand() =>
      _sendCommand('thread.br_init');

  @override
  Future<void> sendThreadBorderRouterDeinitCommand() =>
      _sendCommand('thread.br_deinit');

  @override
  Future<void> sendThreadDatasetInitCommand({
    required int channel,
    required int panId,
    required String networkName,
    required String extendedPanId,
    required String meshLocalPrefix,
    required String networkKey,
    required String pskc,
  }) =>
      _sendCommand(
        'thread.dataset.init',
        payload: {
          'channel': channel,
          'pan_id': panId,
          'network_name': networkName,
          'extended_pan_id': extendedPanId,
          'mesh_local_prefix': meshLocalPrefix,
          'master_key': networkKey,
          'pskc': pskc,
        },
      );

  Future<void> _sendCommand(
    String action, {
    Map<String, Object?>? payload,
  }) async {
    final body = <String, Object?>{
      'type': 'command',
      'action': action,
      if (payload != null) 'payload': payload,
    };

    final sent = await websocket.sendMessage(jsonEncode(body));
    if (!sent) {
      throw StateError('WebSocket is not connected.');
    }
  }
}
