import 'dart:async';

import 'package:dashboard/src/core/errors/app_failure.dart';
import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/devices/domain/entities/device_record.dart';
import 'package:dashboard/src/features/devices/domain/repositories/device_repository.dart';
import 'package:dashboard/src/features/devices/presentation/controllers/device_list_controller.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_message.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('seeds devices from latest snapshot state', () {
    final controller = DeviceListController(
      repository: _DeviceRepo(),
      messages: const Stream.empty(),
      initialDevices: const [
        DeviceRecord(
          deviceId: 'node-1001',
          nodeId: '1001',
          label: 'Snapshot sensor',
          reachable: true,
        ),
      ],
    );

    expect(controller.state.devices.single.label, 'Snapshot sensor');
    controller.dispose();
  });

  test('state_snapshot updates devices without manual refresh', () async {
    final messages = StreamController<OrchestratorMessage>();
    final controller = DeviceListController(
      repository: _DeviceRepo(),
      messages: messages.stream,
    );

    messages.add(
      StateSnapshotReceived(
        OrchestratorSnapshot.fromPayload({
          'devices': [
            {
              'device_id': 'node-1002',
              'node_id': '1002',
              'label': 'Snapshot actuator',
              'reachable': true,
            },
          ],
        }),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.devices.single.deviceId, 'node-1002');
    expect(controller.state.devices.single.label, 'Snapshot actuator');
    expect(controller.state.loading, isFalse);

    await messages.close();
    controller.dispose();
  });

  test(
    'device refresh starts async discovery without listing devices',
    () async {
      final messages = StreamController<OrchestratorMessage>();
      final repository = _DeviceRepo();
      final controller = DeviceListController(
        repository: repository,
        messages: messages.stream,
        initialDevices: const [
          DeviceRecord(
            deviceId: 'node-1001',
            nodeId: '1001',
            label: 'Sensor',
            reachable: true,
          ),
        ],
      );

      await controller.refreshDevice('node-1001');

      expect(repository.refreshDeviceCount, 1);
      expect(repository.listDevicesCount, 0);
      expect(controller.state.pendingDiscoveryDeviceIds, contains('node-1001'));
      expect(controller.state.message, contains('Discovery started'));

      messages.add(
        OrchestratorEventReceived(
          event: 'matter.discovery_complete',
          payload: const {},
          receivedAt: DateTime(2026),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.pendingDiscoveryDeviceIds, isEmpty);
      expect(controller.state.message, contains('discovery complete'));

      await messages.close();
      controller.dispose();
    },
  );
}

final class _DeviceRepo implements DeviceRepository {
  int listDevicesCount = 0;
  int refreshDeviceCount = 0;

  @override
  Future<Result<List<DeviceRecord>>> listDevices() async {
    listDevicesCount += 1;
    return const Success([]);
  }

  @override
  Future<Result<DeviceRecord>> getDevice(String deviceId) async =>
      const FailureResult(UnknownFailure('No device.'));

  @override
  Future<Result<void>> renameDevice(String deviceId, String label) async =>
      const Success(null);

  @override
  Future<Result<void>> refreshDevice(String deviceId) async {
    refreshDeviceCount += 1;
    return Future.value(const Success(null));
  }

  @override
  Future<Result<void>> removeDevice(String deviceId) async =>
      const Success(null);
}
