import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/devices/domain/entities/device_record.dart';
import 'package:dashboard/src/features/devices/domain/repositories/device_repository.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_message.dart';
import 'device_list_state.dart';

final class DeviceListController extends StateNotifier<DeviceListState> {
  final DeviceRepository _repository;
  final StreamSubscription<OrchestratorMessage> _messageSubscription;

  DeviceListController({
    required DeviceRepository repository,
    required Stream<OrchestratorMessage> messages,
    List<DeviceRecord> initialDevices = const [],
  }) : _repository = repository,
       _messageSubscription = messages.listen((_) {}),
       super(DeviceListState(devices: initialDevices)) {
    _messageSubscription
      ..onData(_onMessage)
      ..onError((Object error, StackTrace stackTrace) {
        state = state.copyWith(loading: false, message: error.toString());
      });
  }

  @override
  void dispose() {
    _messageSubscription.cancel();
    super.dispose();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true);
    final result = await _repository.listDevices();
    state = switch (result) {
      Success(value: final devices) => state.copyWith(
        loading: false,
        devices: devices,
        message: null,
      ),
      FailureResult(failure: final failure) => state.copyWith(
        loading: false,
        message: failure.message,
      ),
    };
  }

  Future<void> rename(String deviceId, String label) async {
    state = state.copyWith(loading: true);
    final result = await _repository.renameDevice(deviceId, label);
    switch (result) {
      case Success():
        await refresh();
      case FailureResult(failure: final failure):
        state = state.copyWith(loading: false, message: failure.message);
    }
  }

  Future<void> refreshDevice(String deviceId) async {
    state = state.copyWith(loading: true);
    final result = await _repository.refreshDevice(deviceId);
    switch (result) {
      case Success():
        state = state.copyWith(
          loading: false,
          pendingDiscoveryDeviceIds: {
            ...state.pendingDiscoveryDeviceIds,
            deviceId,
          },
          message:
              'Discovery started. Waiting for Orchestrator registry updates.',
        );
      case FailureResult(failure: final failure):
        state = state.copyWith(loading: false, message: failure.message);
    }
  }

  Future<void> remove(String deviceId) async {
    state = state.copyWith(loading: true);
    final result = await _repository.removeDevice(deviceId);
    switch (result) {
      case Success():
        state = state.copyWith(
          pendingDiscoveryDeviceIds: {
            for (final id in state.pendingDiscoveryDeviceIds)
              if (id != deviceId) id,
          },
        );
        await refresh();
      case FailureResult(failure: final failure):
        state = state.copyWith(loading: false, message: failure.message);
    }
  }

  void _onMessage(OrchestratorMessage message) {
    switch (message) {
      case StateSnapshotReceived(snapshot: final snapshot):
        state = state.copyWith(
          loading: false,
          devices: snapshot.devices,
          message: state.discoveryPending
              ? 'Discovery is pending. Visible devices reflect the latest snapshot.'
              : null,
        );
      case OrchestratorEventReceived(event: final event, payload: final payload)
          when event == 'device.registry_changed':
        _clearPendingFromPayload(
          payload,
          'Device registry updated from Orchestrator.',
        );
      case OrchestratorEventReceived(event: 'matter.discovery_complete'):
        state = state.copyWith(
          loading: false,
          pendingDiscoveryDeviceIds: const {},
          message: 'Matter discovery complete. Latest registry is available.',
        );
      default:
        break;
    }
  }

  void _clearPendingFromPayload(Map<String, Object?> payload, String message) {
    final deviceId = payload['device_id']?.toString();
    final pending = deviceId == null || deviceId.isEmpty
        ? const <String>{}
        : {
            for (final id in state.pendingDiscoveryDeviceIds)
              if (id != deviceId) id,
          };
    state = state.copyWith(
      loading: false,
      pendingDiscoveryDeviceIds: pending,
      message: message,
    );
  }
}
