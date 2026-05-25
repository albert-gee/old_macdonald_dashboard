import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/chamber/domain/repositories/chamber_repository.dart';
import 'package:dashboard/src/features/devices/domain/entities/device_record.dart';
import 'package:dashboard/src/features/devices/domain/repositories/device_repository.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_message.dart';
import 'chamber_state.dart';

final class ChamberController extends StateNotifier<ChamberState> {
  final ChamberRepository _repository;
  final DeviceRepository _deviceRepository;
  final StreamSubscription<OrchestratorMessage> _messageSubscription;

  ChamberController({
    required ChamberRepository repository,
    required DeviceRepository deviceRepository,
    required Stream<OrchestratorMessage> messages,
  }) : _repository = repository,
       _deviceRepository = deviceRepository,
       _messageSubscription = messages.listen((_) {}),
       super(const ChamberState()) {
    _messageSubscription
      ..onData(_onMessage)
      ..onError((Object error, StackTrace stackTrace) {
        state = state.copyWith(error: error.toString(), success: false);
      });
  }

  @override
  void dispose() {
    _messageSubscription.cancel();
    super.dispose();
  }

  Future<void> loadDevices() async {
    state = state.copyWith(
      loadingDevices: true,
      clearError: true,
      clearMessage: true,
    );
    final result = await _deviceRepository.listDevices();
    state = switch (result) {
      Success(value: final devices) => _stateWithDevices(devices),
      FailureResult(failure: final failure) => state.copyWith(
        loadingDevices: false,
        error: failure.message,
        success: false,
      ),
    };
  }

  Future<void> refreshStatus() async {
    state = state.copyWith(loadingStatus: true);
    final result = await _repository.getStatus();
    state = switch (result) {
      Success(value: final status) => state.copyWith(
        loadingStatus: false,
        status: status,
        success: true,
        clearError: true,
      ),
      FailureResult(failure: final failure) => state.copyWith(
        loadingStatus: false,
        error: failure.message,
        success: false,
      ),
    };
  }

  void selectTemperature(DeviceSelection? selection) {
    state = state.copyWith(
      selectedTemperature: selection,
      clearSelectedTemperature: selection == null,
    );
  }

  void selectPressure(DeviceSelection? selection) {
    state = state.copyWith(
      selectedPressure: selection,
      clearSelectedPressure: selection == null,
    );
  }

  void selectRelay(DeviceSelection? selection) {
    state = state.copyWith(
      selectedRelay: selection,
      clearSelectedRelay: selection == null,
    );
  }

  Future<void> readTemperature() async {
    final selection = state.selectedTemperature;
    if (selection == null) {
      state = state.copyWith(error: 'Select a temperature capability.');
      return;
    }
    state = state.copyWith(
      temperature: state.temperature.copyWith(
        commandPending: true,
        waitingForReport: false,
        clearError: true,
      ),
      clearError: true,
    );
    final result = await _repository.readTemperature(selection.deviceId);
    state = switch (result) {
      Success(value: final value) => _stateWithTemperatureResult(value),
      FailureResult(failure: final failure) => state.copyWith(
        temperature: state.temperature.copyWith(
          commandPending: false,
          waitingForReport: false,
          error: failure.message,
        ),
        error: failure.message,
        success: false,
      ),
    };
  }

  Future<void> readPressure() async {
    final selection = state.selectedPressure;
    if (selection == null) {
      state = state.copyWith(error: 'Select a pressure capability.');
      return;
    }
    state = state.copyWith(
      pressure: state.pressure.copyWith(
        commandPending: true,
        waitingForReport: false,
        clearError: true,
      ),
      clearError: true,
    );
    final result = await _repository.readPressure(selection.deviceId);
    state = switch (result) {
      Success(value: final value) => _stateWithPressureResult(value),
      FailureResult(failure: final failure) => state.copyWith(
        pressure: state.pressure.copyWith(
          commandPending: false,
          waitingForReport: false,
          error: failure.message,
        ),
        error: failure.message,
        success: false,
      ),
    };
  }

  Future<void> setRelay(bool on) async {
    final selection = state.selectedRelay;
    if (selection == null) {
      state = state.copyWith(error: 'Select a relay capability.');
      return;
    }
    state = state.copyWith(
      relay: state.relay.copyWith(commandPending: true, clearError: true),
      clearError: true,
    );
    final result = await _repository.setRelay(selection.deviceId, on);
    state = switch (result) {
      Success() => state.copyWith(
        relay: state.relay.copyWith(
          commandPending: false,
          lastCommandedOn: on,
          updatedAt: DateTime.now(),
          clearError: true,
        ),
        message: on ? 'Relay turned on.' : 'Relay turned off.',
        success: true,
      ),
      FailureResult(failure: final failure) => state.copyWith(
        relay: state.relay.copyWith(
          commandPending: false,
          error: failure.message,
        ),
        error: failure.message,
        success: false,
      ),
    };
  }

  ChamberState _stateWithDevices(List<DeviceRecord> devices) {
    final next = state.copyWith(devices: devices, loadingDevices: false);
    return next.copyWith(
      selectedTemperature: _preserveOrFirst(
        next.temperatureOptions,
        state.selectedTemperature,
      ),
      clearSelectedTemperature: next.temperatureOptions.isEmpty,
      selectedPressure: _preserveOrFirst(
        next.pressureOptions,
        state.selectedPressure,
      ),
      clearSelectedPressure: next.pressureOptions.isEmpty,
      selectedRelay: _preserveOrFirst(next.relayOptions, state.selectedRelay),
      clearSelectedRelay: next.relayOptions.isEmpty,
      success: true,
      clearError: true,
    );
  }

  DeviceSelection? _preserveOrFirst(
    List<DeviceSelection> options,
    DeviceSelection? current,
  ) {
    if (options.isEmpty) return null;
    for (final option in options) {
      if (option == current) return option;
    }
    return options.first;
  }

  ChamberState _stateWithTemperatureResult(SensorReadResult result) {
    if (result.value != null) {
      return state.copyWith(
        temperature: state.temperature.copyWith(
          commandPending: false,
          waitingForReport: false,
          value: result.value,
          rawMeasuredValue: result.rawMeasuredValue,
          updatedAt: DateTime.now(),
          clearError: true,
        ),
        message: 'Temperature read completed.',
        success: true,
      );
    }
    if (result.waitingForReport) {
      return state.copyWith(
        temperature: state.temperature.copyWith(
          commandPending: false,
          waitingForReport: true,
          rawMeasuredValue: result.rawMeasuredValue,
          clearError: true,
        ),
        message: 'Temperature read accepted. Waiting for report.',
        success: true,
      );
    }
    return state.copyWith(
      temperature: state.temperature.copyWith(
        commandPending: false,
        waitingForReport: false,
        error: 'Temperature response did not include a value.',
      ),
      error: 'Temperature response did not include a value.',
      success: false,
    );
  }

  ChamberState _stateWithPressureResult(SensorReadResult result) {
    if (result.value != null) {
      return state.copyWith(
        pressure: state.pressure.copyWith(
          commandPending: false,
          waitingForReport: false,
          value: result.value,
          rawMeasuredValue: result.rawMeasuredValue,
          updatedAt: DateTime.now(),
          clearError: true,
        ),
        message: 'Pressure read completed.',
        success: true,
      );
    }
    if (result.waitingForReport) {
      return state.copyWith(
        pressure: state.pressure.copyWith(
          commandPending: false,
          waitingForReport: true,
          rawMeasuredValue: result.rawMeasuredValue,
          clearError: true,
        ),
        message: 'Pressure read accepted. Waiting for report.',
        success: true,
      );
    }
    return state.copyWith(
      pressure: state.pressure.copyWith(
        commandPending: false,
        waitingForReport: false,
        error: 'Pressure response did not include a value.',
      ),
      error: 'Pressure response did not include a value.',
      success: false,
    );
  }

  void _onMessage(OrchestratorMessage message) {
    switch (message) {
      case OrchestratorEventReceived(event: 'matter.attribute_report'):
        _onAttributeReport(message.payload);
      case MatterAttributeReportReceived(report: final report):
        _onAttributeReport({
          'node_id': report.nodeId,
          'endpoint_id': report.endpointId,
          'cluster_id': report.clusterId,
          'attribute_id': report.attributeId,
          'value': report.value,
        });
      default:
        break;
    }
  }

  void _onAttributeReport(Map<String, Object?> payload) {
    final deviceId = payload['device_id']?.toString();
    final semanticType = DeviceCapabilitySemanticType.fromWireValue(
      payload['semantic_type']?.toString(),
    );
    switch (semanticType) {
      case DeviceCapabilitySemanticType.temperature:
        if (deviceId == null ||
            deviceId != state.selectedTemperature?.deviceId) {
          return;
        }
        final value = _double(payload['temperature_celsius']);
        if (value == null) return;
        state = state.copyWith(
          temperature: state.temperature.copyWith(
            commandPending: false,
            waitingForReport: false,
            value: value,
            rawMeasuredValue: _int(payload['raw_measured_value']),
            updatedAt: DateTime.now(),
            clearError: true,
          ),
          message: 'Temperature report received.',
          success: true,
          clearError: true,
        );
      case DeviceCapabilitySemanticType.pressure:
        if (deviceId == null || deviceId != state.selectedPressure?.deviceId) {
          return;
        }
        final value = _double(payload['pressure_kpa']);
        if (value == null) return;
        state = state.copyWith(
          pressure: state.pressure.copyWith(
            commandPending: false,
            waitingForReport: false,
            value: value,
            rawMeasuredValue: _int(payload['raw_measured_value']),
            updatedAt: DateTime.now(),
            clearError: true,
          ),
          message: 'Pressure report received.',
          success: true,
          clearError: true,
        );
      default:
        break;
    }
  }

  double? _double(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  int? _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
