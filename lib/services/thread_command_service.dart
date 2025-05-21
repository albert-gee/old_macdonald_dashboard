import 'package:dashboard/websocket/websocket_client.dart';
import 'i_thread_command_service.dart';

class ThreadCommandService implements IThreadCommandService {
  final WebSocketClient websocket;

  ThreadCommandService({required this.websocket});

  @override
  Future<void> sendThreadEnableCommand() async {
    await websocket.sendJsonMessage({
      'type': 'command',
      'action': 'thread.enable',
    });
  }

  @override
  Future<void> sendThreadDisableCommand() async {
    await websocket.sendJsonMessage({
      'type': 'command',
      'action': 'thread.disable',
    });
  }

  @override
  Future<void> sendThreadDatasetInitCommand({
    required int channel,
    required int panId,
    required String networkName,
    required String extendedPanId,
    required String meshLocalPrefix,
    required String networkKey,
    required String pskc,
  }) async {
    await websocket.sendJsonMessage({
      'type': 'command',
      'action': 'thread.dataset_init',
      'payload': {
        'channel': channel,
        'pan_id': panId,
        'network_name': networkName,
        'extended_pan_id': extendedPanId,
        'mesh_local_prefix': meshLocalPrefix,
        'network_key': networkKey,
        'pskc': pskc,
      },
    });
  }
}
