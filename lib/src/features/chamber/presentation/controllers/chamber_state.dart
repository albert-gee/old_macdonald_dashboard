import 'package:dashboard/src/features/chamber/domain/entities/chamber_status.dart';
import 'package:dashboard/src/features/devices/domain/entities/device_record.dart';

final class ChamberState {
  final List<DeviceRecord> devices;
  final DeviceSelection? selectedTemperature;
  final DeviceSelection? selectedPressure;
  final DeviceSelection? selectedRelay;
  final SensorReadingState<double> temperature;
  final SensorReadingState<double> pressure;
  final RelayControlState relay;
  final bool loadingDevices;
  final bool loadingStatus;
  final ChamberStatus? status;
  final String? message;
  final String? error;
  final bool success;

  const ChamberState({
    this.devices = const [],
    this.selectedTemperature,
    this.selectedPressure,
    this.selectedRelay,
    this.temperature = const SensorReadingState<double>(),
    this.pressure = const SensorReadingState<double>(),
    this.relay = const RelayControlState(),
    this.loadingDevices = false,
    this.loadingStatus = false,
    this.status,
    this.message,
    this.error,
    this.success = false,
  });

  List<DeviceSelection> get temperatureOptions =>
      _options(DeviceCapabilitySemanticType.temperature);

  List<DeviceSelection> get pressureOptions =>
      _options(DeviceCapabilitySemanticType.pressure);

  List<DeviceSelection> get relayOptions =>
      _options(DeviceCapabilitySemanticType.relay);

  bool get loading => loadingDevices || loadingStatus;

  ChamberState copyWith({
    List<DeviceRecord>? devices,
    DeviceSelection? selectedTemperature,
    DeviceSelection? selectedPressure,
    DeviceSelection? selectedRelay,
    bool clearSelectedTemperature = false,
    bool clearSelectedPressure = false,
    bool clearSelectedRelay = false,
    SensorReadingState<double>? temperature,
    SensorReadingState<double>? pressure,
    RelayControlState? relay,
    bool? loadingDevices,
    bool? loadingStatus,
    ChamberStatus? status,
    String? message,
    String? error,
    bool clearMessage = false,
    bool clearError = false,
    bool? success,
  }) {
    return ChamberState(
      devices: devices ?? this.devices,
      selectedTemperature: clearSelectedTemperature
          ? null
          : selectedTemperature ?? this.selectedTemperature,
      selectedPressure: clearSelectedPressure
          ? null
          : selectedPressure ?? this.selectedPressure,
      selectedRelay: clearSelectedRelay
          ? null
          : selectedRelay ?? this.selectedRelay,
      temperature: temperature ?? this.temperature,
      pressure: pressure ?? this.pressure,
      relay: relay ?? this.relay,
      loadingDevices: loadingDevices ?? this.loadingDevices,
      loadingStatus: loadingStatus ?? this.loadingStatus,
      status: status ?? this.status,
      message: clearMessage ? null : message ?? this.message,
      error: clearError ? null : error ?? this.error,
      success: success ?? this.success,
    );
  }

  List<DeviceSelection> _options(DeviceCapabilitySemanticType semanticType) {
    return [
      for (final device in devices)
        for (final capability in device.capabilities)
          if (capability.semanticType == semanticType)
            if (capability.isValid)
              DeviceSelection(
                deviceId: device.deviceId,
                deviceLabel: device.label,
                reachable: device.reachable,
                capability: capability,
              ),
    ];
  }
}

final class DeviceSelection {
  final String deviceId;
  final String deviceLabel;
  final bool reachable;
  final DeviceCapability capability;

  const DeviceSelection({
    required this.deviceId,
    required this.deviceLabel,
    required this.reachable,
    required this.capability,
  });

  String get label => '$deviceLabel - ${capability.label}';

  @override
  bool operator ==(Object other) {
    return other is DeviceSelection &&
        other.deviceId == deviceId &&
        other.capability.capabilityId == capability.capabilityId;
  }

  @override
  int get hashCode => Object.hash(deviceId, capability.capabilityId);
}

final class SensorReadingState<T> {
  final bool commandPending;
  final bool waitingForReport;
  final T? value;
  final int? rawMeasuredValue;
  final DateTime? updatedAt;
  final String? error;

  const SensorReadingState({
    this.commandPending = false,
    this.waitingForReport = false,
    this.value,
    this.rawMeasuredValue,
    this.updatedAt,
    this.error,
  });

  SensorReadingState<T> copyWith({
    bool? commandPending,
    bool? waitingForReport,
    T? value,
    int? rawMeasuredValue,
    DateTime? updatedAt,
    String? error,
    bool clearError = false,
  }) {
    return SensorReadingState<T>(
      commandPending: commandPending ?? this.commandPending,
      waitingForReport: waitingForReport ?? this.waitingForReport,
      value: value ?? this.value,
      rawMeasuredValue: rawMeasuredValue ?? this.rawMeasuredValue,
      updatedAt: updatedAt ?? this.updatedAt,
      error: clearError ? null : error ?? this.error,
    );
  }
}

final class RelayControlState {
  final bool commandPending;
  final bool? lastCommandedOn;
  final DateTime? updatedAt;
  final String? error;

  const RelayControlState({
    this.commandPending = false,
    this.lastCommandedOn,
    this.updatedAt,
    this.error,
  });

  RelayControlState copyWith({
    bool? commandPending,
    bool? lastCommandedOn,
    DateTime? updatedAt,
    String? error,
    bool clearError = false,
  }) {
    return RelayControlState(
      commandPending: commandPending ?? this.commandPending,
      lastCommandedOn: lastCommandedOn ?? this.lastCommandedOn,
      updatedAt: updatedAt ?? this.updatedAt,
      error: clearError ? null : error ?? this.error,
    );
  }
}
