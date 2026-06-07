import 'package:dashboard/src/core/websocket/websocket_connection_status.dart';
import 'package:dashboard/src/features/chamber/presentation/controllers/chamber_state.dart';
import 'package:dashboard/src/features/devices/domain/entities/device_record.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_snapshot.dart';
import 'package:dashboard/src/features/orchestrator/presentation/controllers/orchestrator_connection_state.dart';
import 'package:dashboard/src/features/orchestrator/presentation/controllers/orchestrator_runtime_state.dart';
import 'package:dashboard/src/features/overview/domain/operator_runtime.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('next action starts with connection when disconnected', () {
    final runtime = _runtime();

    expect(runtime.nextAction.target, OperatorNextActionTarget.connect);
    expect(runtime.nextAction.title, 'Connect to Orchestrator');
  });

  test('next action reports Matter platform failure before setup actions', () {
    final runtime = _runtime(
      connected: true,
      snapshot: _snapshot(
        thread: {'dataset_present': true, 'enabled': true},
        matter: {
          'platform_initialized': false,
          'platform_error': 'MATTER_PLATFORM_INIT_FAILED:ESP_FAIL',
        },
      ),
    );

    expect(runtime.matterPlatformFailed, isTrue);
    expect(runtime.nextAction.target, OperatorNextActionTarget.diagnostics);
    expect(runtime.nextAction.title, 'Matter platform failed');
  });

  test(
    'next action follows Thread, Matter, device, chamber, and rule order',
    () {
      expect(
        _runtime(connected: true, snapshot: _snapshot()).nextAction.title,
        'Create Thread dataset',
      );
      expect(
        _runtime(
          connected: true,
          snapshot: _snapshot(thread: {'dataset_present': true}),
        ).nextAction.title,
        'Enable Thread',
      );
      expect(
        _runtime(
          connected: true,
          snapshot: _snapshot(
            thread: {'dataset_present': true, 'enabled': true},
          ),
        ).nextAction.title,
        'Initialize Matter controller',
      );
      expect(
        _runtime(
          connected: true,
          snapshot: _snapshot(
            thread: {'dataset_present': true, 'enabled': true},
            matter: {'controller_initialized': true},
          ),
        ).nextAction.title,
        'Commission a device',
      );
      expect(
        _runtime(
          connected: true,
          snapshot: _snapshot(
            thread: {'dataset_present': true, 'enabled': true},
            matter: {'controller_initialized': true},
          ),
          devices: [_device()],
        ).nextAction.title,
        'Assign chamber devices',
      );
      expect(
        _runtime(
          connected: true,
          snapshot: _snapshot(
            thread: {'dataset_present': true, 'enabled': true},
            matter: {'controller_initialized': true},
            chambers: [
              {
                'temperature_source': {
                  'device_id': 'sensor-1',
                  'capability_id': 'temp-1',
                },
                'fan_actuator': {
                  'device_id': 'relay-1',
                  'capability_id': 'onoff-1',
                },
              },
            ],
          ),
          devices: [_device()],
        ).nextAction.title,
        'Configure cooling rule',
      );
      expect(
        _runtime(
          connected: true,
          snapshot: _snapshot(
            thread: {'dataset_present': true, 'enabled': true},
            matter: {'controller_initialized': true},
            chambers: [
              {
                'temperature_source': {
                  'device_id': 'sensor-1',
                  'capability_id': 'temp-1',
                },
                'fan_actuator': {
                  'device_id': 'relay-1',
                  'capability_id': 'onoff-1',
                },
              },
            ],
            controlRules: [
              {
                'configured': true,
                'sensor': {'device_id': 'sensor-1', 'capability_id': 'temp-1'},
                'actuator': {
                  'device_id': 'relay-1',
                  'capability_id': 'onoff-1',
                },
              },
            ],
          ),
          devices: [_device()],
        ).nextAction.title,
        'System ready',
      );
    },
  );
}

OperatorRuntime _runtime({
  bool connected = false,
  OrchestratorSnapshot? snapshot,
  List<DeviceRecord> devices = const [],
  ChamberState chamber = const ChamberState(),
}) {
  return OperatorRuntime(
    connection: OrchestratorConnectionState(
      url: 'wss://192.168.4.1/ws',
      status: connected
          ? WebSocketConnectionStatus.connected
          : WebSocketConnectionStatus.disconnected,
    ),
    runtime: OrchestratorRuntimeState(snapshot: snapshot),
    devices: devices,
    chamber: chamber,
  );
}

OrchestratorSnapshot _snapshot({
  Map<String, Object?> thread = const {},
  Map<String, Object?> matter = const {},
  List<Map<String, Object?>> chambers = const [],
  List<Map<String, Object?>> controlRules = const [],
}) {
  return OrchestratorSnapshot.fromPayload({
    'thread': thread,
    'matter': matter,
    'chambers': chambers,
    'control_rules': controlRules,
  });
}

DeviceRecord _device() {
  return const DeviceRecord(
    deviceId: 'sensor-1',
    nodeId: '1001',
    label: 'Environmental sensor',
    reachable: true,
  );
}
