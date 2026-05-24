import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/chamber/domain/repositories/chamber_repository.dart';
import 'chamber_state.dart';

final class ChamberController extends StateNotifier<ChamberState> {
  final ChamberRepository _repository;

  ChamberController({required ChamberRepository repository})
    : _repository = repository,
      super(const ChamberState());

  Future<void> refreshStatus() async {
    state = state.copyWith(loading: true);
    final result = await _repository.getStatus();
    state = switch (result) {
      Success(value: final status) => state.copyWith(
        loading: false,
        status: status,
        success: true,
      ),
      FailureResult(failure: final failure) => state.copyWith(
        loading: false,
        message: failure.message,
        success: false,
      ),
    };
  }

  Future<void> readTemperature(String deviceId) async {
    state = state.copyWith(loading: true);
    final result = await _repository.readTemperature(deviceId);
    state = switch (result) {
      Success(value: final value) => state.copyWith(
        loading: false,
        lastTemperatureCelsius: value,
        message: 'Temperature read completed.',
        success: true,
      ),
      FailureResult(failure: final failure) => state.copyWith(
        loading: false,
        message: failure.message,
        success: false,
      ),
    };
  }

  Future<void> readPressure(String deviceId) async {
    state = state.copyWith(loading: true);
    final result = await _repository.readPressure(deviceId);
    state = switch (result) {
      Success(value: final value) => state.copyWith(
        loading: false,
        lastPressureKpa: value,
        message: 'Pressure read completed.',
        success: true,
      ),
      FailureResult(failure: final failure) => state.copyWith(
        loading: false,
        message: failure.message,
        success: false,
      ),
    };
  }

  Future<void> setRelay(String deviceId, bool on) async {
    state = state.copyWith(loading: true);
    final result = await _repository.setRelay(deviceId, on);
    state = switch (result) {
      Success() => state.copyWith(
        loading: false,
        message: on ? 'Relay turned on.' : 'Relay turned off.',
        success: true,
      ),
      FailureResult(failure: final failure) => state.copyWith(
        loading: false,
        message: failure.message,
        success: false,
      ),
    };
  }
}
