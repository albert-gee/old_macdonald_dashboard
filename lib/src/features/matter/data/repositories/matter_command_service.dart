import 'dart:convert';
import 'package:dashboard/websocket/i_websocket_client.dart';
import 'i_matter_command_service.dart';

class MatterCommandService implements IMatterCommandService {
  final IWebSocketClient websocket;

  MatterCommandService({required this.websocket});

  @override
  Future<void> initializeController({
    required int nodeId,
    required int fabricId,
    required int listenPort,
  }) async {
    final message = jsonEncode({
      'type': 'command',
      'action': 'matter.controller_init',
      'payload': {
        'node_id': nodeId,
        'fabric_id': fabricId,
        'listen_port': listenPort,
      },
    });

    final sent = await websocket.sendMessage(message);
    if (!sent) {
      throw StateError('WebSocket is not connected.');
    }
  }

  @override
  Future<void> pairBleThread({
    required String nodeId,
    required String setupCode,
    required String discriminator,
  }) async {
    final message = jsonEncode({
      'type': 'command',
      'action': 'matter.pair_ble_thread',
      'payload': {
        'node_id': nodeId,
        'setup_code': setupCode,
        'discriminator': discriminator,
      },
    });

    final sent = await websocket.sendMessage(message);
    if (!sent) {
      throw StateError('WebSocket is not connected.');
    }
  }

  @override
  Future<void> invokeClusterCommand({
    required String destinationId,
    required int endpointId,
    required int clusterId,
    required int commandId,
    required String commandData,
  }) async {
    final message = jsonEncode({
      'type': 'command',
      'action': 'matter.cluster_command_invoke',
      'payload': {
        'destination_id': destinationId,
        'endpoint_id': endpointId,
        'cluster_id': clusterId,
        'command_id': commandId,
        'command_data': commandData,
      },
    });

    final sent = await websocket.sendMessage(message);
    if (!sent) {
      throw StateError('WebSocket is not connected.');
    }
  }

  @override
  Future<void> readAttribute({
    required String nodeId,
    required int endpointId,
    required int clusterId,
    required int attributeId,
  }) async {
    final message = jsonEncode({
      'type': 'command',
      'action': 'matter.attribute_read',
      'payload': {
        'node_id': nodeId,
        'endpoint_id': endpointId,
        'cluster_id': clusterId,
        'attribute_id': attributeId,
      },
    });

    final sent = await websocket.sendMessage(message);
    if (!sent) {
      throw StateError('WebSocket is not connected.');
    }
  }

  @override
  Future<void> subscribeAttribute({
    required String nodeId,
    required int endpointId,
    required int clusterId,
    required int attributeId,
    required int minInterval,
    required int maxInterval,
  }) async {
    final message = jsonEncode({
      'type': 'command',
      'action': 'matter.attribute_subscribe',
      'payload': {
        'node_id': nodeId,
        'endpoint_id': endpointId,
        'cluster_id': clusterId,
        'attribute_id': attributeId,
        'min_interval': minInterval,
        'max_interval': maxInterval,
      },
    });

    final sent = await websocket.sendMessage(message);
    if (!sent) {
      throw StateError('WebSocket is not connected.');
    }
  }
}
