import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/devices/domain/repositories/device_repository.dart';
import 'device_list_state.dart';

final class DeviceListController extends StateNotifier<DeviceListState> {
  final DeviceRepository _repository;

  DeviceListController({required DeviceRepository repository})
    : _repository = repository,
      super(const DeviceListState());

  Future<void> refresh() async {
    state = state.copyWith(loading: true);
    final result = await _repository.listDevices();
    state = switch (result) {
      Success(value: final devices) => DeviceListState(
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
        await refresh();
      case FailureResult(failure: final failure):
        state = state.copyWith(loading: false, message: failure.message);
    }
  }

  Future<void> remove(String deviceId) async {
    state = state.copyWith(loading: true);
    final result = await _repository.removeDevice(deviceId);
    switch (result) {
      case Success():
        await refresh();
      case FailureResult(failure: final failure):
        state = state.copyWith(loading: false, message: failure.message);
    }
  }
}
