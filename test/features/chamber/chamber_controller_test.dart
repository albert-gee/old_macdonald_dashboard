import 'dart:async';

import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/chamber/domain/entities/chamber_status.dart';
import 'package:dashboard/src/features/chamber/domain/repositories/chamber_repository.dart';
import 'package:dashboard/src/features/chamber/presentation/controllers/chamber_controller.dart';
import 'package:dashboard/src/features/devices/domain/entities/device_record.dart';
import 'package:dashboard/src/features/devices/domain/repositories/device_repository.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_message.dart';
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

  FakeChamberRepository({
    this.temperatureResult = const SensorReadResult(),
    this.pressureResult = const SensorReadResult(),
  });

  @override
  Future<Result<ChamberStatus>> getStatus() async =>
      const Success(ChamberStatus());

  @override
  Future<Result<SensorReadResult>> readTemperature(String deviceId) async =>
      Success(temperatureResult);

  @override
  Future<Result<SensorReadResult>> readPressure(String deviceId) async =>
      Success(pressureResult);

  @override
  Future<Result<void>> setRelay(String deviceId, bool on) async =>
      const Success(null);
}
