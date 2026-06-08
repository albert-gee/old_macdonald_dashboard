import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses full state_snapshot payload', () {
    final snapshot = OrchestratorSnapshot.fromPayload({
      'wifi': {
        'mode': 'apsta',
        'ap_running': true,
        'sta_configured': true,
        'sta_connected': true,
        'sta_ip': '192.168.1.2',
        'rssi': -42,
      },
      'thread': {
        'enabled': true,
        'attached': true,
        'role': 'leader',
        'dataset_present': true,
        'dataset': {
          'network_name': 'OldMacdonald',
          'channel': 15,
          'pan_id': 4660,
          'extended_pan_id': '1122334455667788',
          'mesh_local_prefix': 'fd11:22::',
        },
        'border_router_initialized': true,
      },
      'matter': {
        'platform_initialized': false,
        'platform_error': 'MATTER_PLATFORM_INIT_FAILED:ESP_FAIL',
        'controller_initialized': true,
        'commissioned_nodes': [
          {'node_id': 123, 'label': 'Sensor', 'reachable': true},
        ],
      },
      'devices': [
        {
          'device_id': 'node-1001',
          'node_id': '1001',
          'label': 'Environmental sensor',
          'reachable': true,
          'capabilities': [
            {
              'capability_id': 'node-1001-ep1-temperature',
              'semantic_type': 'temperature',
              'endpoint_id': 1,
              'cluster_id': 1026,
              'attribute_id': 0,
              'label': 'Temperature',
            },
          ],
        },
      ],
      'websocket': {'clients': 2},
    });

    expect(snapshot.wifi.apRunning, isTrue);
    expect(snapshot.wifi.staIp, '192.168.1.2');
    expect(snapshot.thread.role, 'leader');
    expect(snapshot.thread.networkName, 'OldMacdonald');
    expect(snapshot.thread.channel, 15);
    expect(snapshot.thread.panId, 4660);
    expect(snapshot.thread.extendedPanId, '1122334455667788');
    expect(snapshot.thread.meshLocalPrefix, 'fd11:22::');
    expect(snapshot.thread.borderRouterInitialized, isTrue);
    expect(snapshot.matter.platformInitialized, isFalse);
    expect(
      snapshot.matter.platformError,
      'MATTER_PLATFORM_INIT_FAILED:ESP_FAIL',
    );
    expect(snapshot.matter.commissionedNodes.single.nodeId, '123');
    expect(snapshot.devices.single.deviceId, 'node-1001');
    expect(
      snapshot.devices.single.capabilities.single.capabilityId,
      'node-1001-ep1-temperature',
    );
    expect(snapshot.websocket.clients, 2);
  });

  test('partial snapshot uses safe defaults', () {
    final snapshot = OrchestratorSnapshot.fromPayload({});
    expect(snapshot.wifi.apRunning, isFalse);
    expect(snapshot.thread.role, 'unknown');
    expect(snapshot.thread.networkName, isNull);
    expect(snapshot.matter.platformInitialized, isNull);
    expect(snapshot.matter.platformError, isNull);
    expect(snapshot.matter.commissionedNodes, isEmpty);
    expect(snapshot.devices, isEmpty);
    expect(snapshot.websocket.clients, 0);
  });
}
