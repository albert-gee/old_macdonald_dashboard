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
      },
      'matter': {
        'controller_initialized': true,
        'commissioned_nodes': [
          {'node_id': 123, 'label': 'Sensor', 'reachable': true},
        ],
      },
      'websocket': {'clients': 2},
    });

    expect(snapshot.wifi.apRunning, isTrue);
    expect(snapshot.wifi.staIp, '192.168.1.2');
    expect(snapshot.thread.role, 'leader');
    expect(snapshot.matter.commissionedNodes.single.nodeId, '123');
    expect(snapshot.websocket.clients, 2);
  });

  test('partial snapshot uses safe defaults', () {
    final snapshot = OrchestratorSnapshot.fromPayload({});
    expect(snapshot.wifi.apRunning, isFalse);
    expect(snapshot.thread.role, 'unknown');
    expect(snapshot.matter.commissionedNodes, isEmpty);
    expect(snapshot.websocket.clients, 0);
  });
}
