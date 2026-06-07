import 'dart:async';

import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/chamber/domain/entities/chamber_status.dart';
import 'package:dashboard/src/features/chamber/domain/repositories/chamber_repository.dart';
import 'package:dashboard/src/features/chamber/presentation/controllers/chamber_controller.dart';
import 'package:dashboard/src/features/devices/domain/entities/device_record.dart';
import 'package:dashboard/src/features/devices/domain/repositories/device_repository.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_message.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds capability options from device registry', () async {
    final messages = StreamController<OrchestratorMessage>();
    final controller = ChamberController(
      repository: FakeChamberRepository(),
      deviceRepository: FakeDeviceRepository(devices: _devices()),
      messages: messages.stream,
    );
    await controller.loadDevices();

    expect(
      controller.state.temperatureOptions.single.label,
      'Environmental sensor - Temperature',
    );
    expect(
      controller.state.pressureOptions.single.label,
      'Environmental sensor - Pressure',
    );
    expect(
      controller.state.relayOptions.single.label,
      'Switchable actuator - On/Off',
    );

    controller.dispose();
    await messages.close();
  });

  test('handles synchronous temperature read', () async {
    final messages = StreamController<OrchestratorMessage>();
    final repository = FakeChamberRepository(
      temperatureResult: const SensorReadResult(value: 23.4),
    );
    final controller = ChamberController(
      repository: repository,
      deviceRepository: FakeDeviceRepository(devices: _devices()),
      messages: messages.stream,
    );
    await controller.loadDevices();
    await controller.readTemperature();

    expect(controller.state.temperature.value, 23.4);
    expect(controller.state.temperature.waitingForReport, false);
    expect(repository.temperatureReads.single.deviceId, 'sensor-1');
    expect(repository.temperatureReads.single.capabilityId, 'capability-1');

    controller.dispose();
    await messages.close();
  });

  test('accepted async temperature read waits for attribute report', () async {
    final messages = StreamController<OrchestratorMessage>();
    final repository = FakeChamberRepository(
      temperatureResult: const SensorReadResult(
        accepted: true,
        resultDelivery: 'matter.attribute_report',
      ),
    );
    final controller = ChamberController(
      repository: repository,
      deviceRepository: FakeDeviceRepository(devices: _devices()),
      messages: messages.stream,
    );
    await controller.loadDevices();
    await controller.readTemperature();

    expect(controller.state.temperature.waitingForReport, true);

    controller.dispose();
    await messages.close();
  });

  test(
    'matter.attribute_report updates selected temperature and pressure',
    () async {
      final messages = StreamController<OrchestratorMessage>();
      final controller = ChamberController(
        repository: FakeChamberRepository(),
        deviceRepository: FakeDeviceRepository(devices: _devices()),
        messages: messages.stream,
      );
      await controller.loadDevices();

      messages.add(
        OrchestratorEventReceived(
          event: 'matter.attribute_report',
          payload: {
            'device_id': 'sensor-1',
            'capability_id': 'capability-1',
            'semantic_type': 'temperature',
            'temperature_celsius': 24.1,
            'raw_measured_value': 2410,
          },
          receivedAt: DateTime.now(),
        ),
      );
      messages.add(
        OrchestratorEventReceived(
          event: 'matter.attribute_report',
          payload: {
            'device_id': 'sensor-1',
            'capability_id': 'capability-2',
            'semantic_type': 'pressure',
            'pressure_kpa': 101.3,
            'raw_measured_value': 1013,
          },
          receivedAt: DateTime.now(),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.temperature.value, 24.1);
      expect(controller.state.temperature.rawMeasuredValue, 2410);
      expect(controller.state.pressure.value, 101.3);

      controller.dispose();
      await messages.close();
    },
  );

  test('ignores unrelated and incomplete reports', () async {
    final messages = StreamController<OrchestratorMessage>();
    final controller = ChamberController(
      repository: FakeChamberRepository(),
      deviceRepository: FakeDeviceRepository(devices: _devices()),
      messages: messages.stream,
    );
    await controller.loadDevices();

    messages
      ..add(
        OrchestratorEventReceived(
          event: 'matter.attribute_report',
          payload: {
            'device_id': 'other',
            'capability_id': 'capability-1',
            'semantic_type': 'temperature',
            'temperature_celsius': 99.0,
          },
          receivedAt: DateTime.now(),
        ),
      )
      ..add(
        OrchestratorEventReceived(
          event: 'matter.attribute_report',
          payload: {'semantic_type': 'pressure', 'pressure_kpa': 99.0},
          receivedAt: DateTime.now(),
        ),
      )
      ..add(
        OrchestratorEventReceived(
          event: 'other.event',
          payload: const {'temperature_celsius': 99.0},
          receivedAt: DateTime.now(),
        ),
      );
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.temperature.value, isNull);
    expect(controller.state.pressure.value, isNull);

    controller.dispose();
    await messages.close();
  });

  test(
    'readTemperature and readPressure include selected capability IDs',
    () async {
      final messages = StreamController<OrchestratorMessage>();
      final repository = FakeChamberRepository(
        temperatureResult: const SensorReadResult(value: 23.4),
        pressureResult: const SensorReadResult(value: 101.3),
      );
      final controller = ChamberController(
        repository: repository,
        deviceRepository: FakeDeviceRepository(devices: _devices()),
        messages: messages.stream,
      );
      await controller.loadDevices();

      await controller.readTemperature();
      await controller.readPressure();

      expect(
        repository.temperatureReads.single,
        const SensorReadCall('sensor-1', 'capability-1'),
      );
      expect(
        repository.pressureReads.single,
        const SensorReadCall('sensor-1', 'capability-2'),
      );

      controller.dispose();
      await messages.close();
    },
  );

  test('setControlEnabled(true) saves and enables when disabled', () async {
    final messages = StreamController<OrchestratorMessage>();
    final repository = FakeChamberRepository();
    final controller = ChamberController(
      repository: repository,
      deviceRepository: FakeDeviceRepository(devices: _devices()),
      messages: messages.stream,
    );
    await controller.loadDevices();

    await controller.setControlEnabled(true);

    expect(controller.state.controlEnabled, isTrue);
    expect(controller.state.controlState, 'idle');
    final savedRule = repository.savedRules.single;
    expect(savedRule.sensorDeviceId, 'sensor-1');
    expect(savedRule.sensorCapabilityId, 'capability-1');
    expect(savedRule.actuatorDeviceId, 'actuator-1');
    expect(savedRule.actuatorCapabilityId, 'capability-3');
    expect(savedRule.enabled, isTrue);
    expect(repository.enabledRequests, isEmpty);

    controller.dispose();
    await messages.close();
  });

  test(
    'state_snapshot restores devices, selected capabilities, and control state',
    () async {
      final messages = StreamController<OrchestratorMessage>();
      final controller = ChamberController(
        repository: FakeChamberRepository(),
        deviceRepository: FakeDeviceRepository(devices: const []),
        messages: messages.stream,
      );

      messages.add(
        StateSnapshotReceived(
          OrchestratorSnapshot.fromPayload({
            'devices': [
              {
                'device_id': 'sensor-1',
                'node_id': '123',
                'label': 'Environmental sensor',
                'reachable': true,
                'capabilities': [
                  {
                    'capability_id': 'temperature-a',
                    'semantic_type': 'temperature',
                    'endpoint_id': 1,
                    'cluster_id': 1026,
                    'attribute_id': 0,
                    'label': 'Temperature A',
                  },
                  {
                    'capability_id': 'temperature-b',
                    'semantic_type': 'temperature',
                    'endpoint_id': 2,
                    'cluster_id': 1026,
                    'attribute_id': 0,
                    'label': 'Temperature B',
                  },
                  {
                    'capability_id': 'pressure-a',
                    'semantic_type': 'pressure',
                    'endpoint_id': 3,
                    'cluster_id': 1027,
                    'attribute_id': 0,
                    'label': 'Pressure A',
                  },
                ],
              },
              {
                'device_id': 'actuator-1',
                'node_id': '987',
                'label': 'Switchable actuator',
                'reachable': true,
                'capabilities': [
                  {
                    'capability_id': 'relay-a',
                    'semantic_type': 'relay',
                    'endpoint_id': 1,
                    'cluster_id': 6,
                    'command_id': 1,
                    'label': 'Relay A',
                  },
                  {
                    'capability_id': 'relay-b',
                    'semantic_type': 'relay',
                    'endpoint_id': 2,
                    'cluster_id': 6,
                    'command_id': 1,
                    'label': 'Relay B',
                  },
                ],
              },
            ],
            'chambers': [
              {
                'chamber_id': 'main',
                'temperature_celsius': 25.2,
                'pressure_kpa': 100.9,
                'relay_on': true,
              },
            ],
            'control_rules': [
              {
                'rule_id': 'main-air-temperature-fan',
                'chamber_id': 'main',
                'enabled': true,
                'state': 'cooling',
                'min_celsius': 22.5,
                'max_celsius': 27.5,
                'sensor': {
                  'device_id': 'sensor-1',
                  'capability_id': 'temperature-b',
                },
                'actuator': {
                  'device_id': 'actuator-1',
                  'capability_id': 'relay-b',
                },
              },
            ],
          }),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.devices, hasLength(2));
      expect(
        controller.state.selectedTemperature?.capability.capabilityId,
        'temperature-b',
      );
      expect(
        controller.state.selectedRelay?.capability.capabilityId,
        'relay-b',
      );
      expect(controller.state.temperature.value, 25.2);
      expect(controller.state.pressure.value, 100.9);
      expect(controller.state.relay.lastCommandedOn, isTrue);
      expect(controller.state.minCelsius, 22.5);
      expect(controller.state.maxCelsius, 27.5);
      expect(controller.state.controlEnabled, isTrue);
      expect(controller.state.controlState, 'cooling');

      controller.dispose();
      await messages.close();
    },
  );

  test('control.rule_action updates relay and control state', () async {
    final messages = StreamController<OrchestratorMessage>();
    final controller = ChamberController(
      repository: FakeChamberRepository(),
      deviceRepository: FakeDeviceRepository(devices: _devices()),
      messages: messages.stream,
    );
    await controller.loadDevices();

    messages.add(
      OrchestratorEventReceived(
        event: 'control.rule_action',
        payload: const {'command': 'on'},
        receivedAt: DateTime.now(),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.controlState, 'cooling');
    expect(controller.state.relay.lastCommandedOn, isTrue);

    controller.dispose();
    await messages.close();
  });

  test(
    'attribute_report ignores same-device wrong-capability reports',
    () async {
      final messages = StreamController<OrchestratorMessage>();
      final controller = ChamberController(
        repository: FakeChamberRepository(),
        deviceRepository: FakeDeviceRepository(devices: _devices()),
        messages: messages.stream,
      );
      await controller.loadDevices();

      messages
        ..add(
          OrchestratorEventReceived(
            event: 'matter.attribute_report',
            payload: {
              'device_id': 'sensor-1',
              'capability_id': 'other-temperature',
              'semantic_type': 'temperature',
              'temperature_celsius': 99.0,
            },
            receivedAt: DateTime.now(),
          ),
        )
        ..add(
          OrchestratorEventReceived(
            event: 'matter.attribute_report',
            payload: {
              'device_id': 'sensor-1',
              'capability_id': 'other-pressure',
              'semantic_type': 'pressure',
              'pressure_kpa': 99.0,
            },
            receivedAt: DateTime.now(),
          ),
        );
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.temperature.value, isNull);
      expect(controller.state.pressure.value, isNull);

      controller.dispose();
      await messages.close();
    },
  );
}

List<DeviceRecord> _devices() {
  return const [
    DeviceRecord(
      deviceId: 'sensor-1',
      nodeId: '123',
      label: 'Environmental sensor',
      reachable: true,
      capabilities: [
        DeviceCapability(
          capabilityId: 'capability-1',
          semanticType: DeviceCapabilitySemanticType.temperature,
          endpointId: 1,
          clusterId: 1026,
          attributeId: 0,
          label: 'Temperature',
        ),
        DeviceCapability(
          capabilityId: 'capability-2',
          semanticType: DeviceCapabilitySemanticType.pressure,
          endpointId: 2,
          clusterId: 1027,
          attributeId: 0,
          label: 'Pressure',
        ),
      ],
    ),
    DeviceRecord(
      deviceId: 'actuator-1',
      nodeId: '987',
      label: 'Switchable actuator',
      reachable: true,
      capabilities: [
        DeviceCapability(
          capabilityId: 'capability-3',
          semanticType: DeviceCapabilitySemanticType.relay,
          endpointId: 1,
          clusterId: 6,
          commandId: 1,
          label: 'On/Off',
        ),
      ],
    ),
  ];
}

final class FakeDeviceRepository implements DeviceRepository {
  final List<DeviceRecord> devices;

  FakeDeviceRepository({required this.devices});

  @override
  Future<Result<List<DeviceRecord>>> listDevices() async => Success(devices);

  @override
  Future<Result<DeviceRecord>> getDevice(String deviceId) async =>
      Success(devices.firstWhere((device) => device.deviceId == deviceId));

  @override
  Future<Result<void>> renameDevice(String deviceId, String label) async =>
      const Success(null);

  @override
  Future<Result<void>> removeDevice(String deviceId) async =>
      const Success(null);
}

final class FakeChamberRepository implements ChamberRepository {
  final SensorReadResult temperatureResult;
  final SensorReadResult pressureResult;
  final List<SensorReadCall> temperatureReads = [];
  final List<SensorReadCall> pressureReads = [];
  final List<SavedTemperatureRuleCall> savedRules = [];
  final List<bool> enabledRequests = [];

  FakeChamberRepository({
    this.temperatureResult = const SensorReadResult(),
    this.pressureResult = const SensorReadResult(),
  });

  @override
  Future<Result<ChamberStatus>> getStatus() async =>
      const Success(ChamberStatus());

  @override
  Future<Result<SensorReadResult>> readTemperature(
    String deviceId,
    String capabilityId,
  ) async {
    temperatureReads.add(SensorReadCall(deviceId, capabilityId));
    return Success(temperatureResult);
  }

  @override
  Future<Result<SensorReadResult>> readPressure(
    String deviceId,
    String capabilityId,
  ) async {
    pressureReads.add(SensorReadCall(deviceId, capabilityId));
    return Success(pressureResult);
  }

  @override
  Future<Result<void>> setRelay(
    String deviceId,
    String capabilityId,
    bool on,
  ) async => const Success(null);

  @override
  Future<Result<ChamberControlRule>> saveTemperatureRule({
    required String sensorDeviceId,
    required String sensorCapabilityId,
    required String actuatorDeviceId,
    required String actuatorCapabilityId,
    required double minCelsius,
    required double maxCelsius,
    required bool enabled,
  }) async {
    savedRules.add(
      SavedTemperatureRuleCall(
        sensorDeviceId: sensorDeviceId,
        sensorCapabilityId: sensorCapabilityId,
        actuatorDeviceId: actuatorDeviceId,
        actuatorCapabilityId: actuatorCapabilityId,
        minCelsius: minCelsius,
        maxCelsius: maxCelsius,
        enabled: enabled,
      ),
    );
    return Success(
      ChamberControlRule(
        configured: true,
        enabled: enabled,
        minCelsius: minCelsius,
        maxCelsius: maxCelsius,
        state: enabled ? 'idle' : 'disabled',
      ),
    );
  }

  @override
  Future<Result<void>> setTemperatureControlEnabled(bool enabled) async {
    enabledRequests.add(enabled);
    return const Success(null);
  }
}

final class SensorReadCall {
  final String deviceId;
  final String capabilityId;

  const SensorReadCall(this.deviceId, this.capabilityId);

  @override
  bool operator ==(Object other) {
    return other is SensorReadCall &&
        other.deviceId == deviceId &&
        other.capabilityId == capabilityId;
  }

  @override
  int get hashCode => Object.hash(deviceId, capabilityId);
}

final class SavedTemperatureRuleCall {
  final String sensorDeviceId;
  final String sensorCapabilityId;
  final String actuatorDeviceId;
  final String actuatorCapabilityId;
  final double minCelsius;
  final double maxCelsius;
  final bool enabled;

  const SavedTemperatureRuleCall({
    required this.sensorDeviceId,
    required this.sensorCapabilityId,
    required this.actuatorDeviceId,
    required this.actuatorCapabilityId,
    required this.minCelsius,
    required this.maxCelsius,
    required this.enabled,
  });
}
