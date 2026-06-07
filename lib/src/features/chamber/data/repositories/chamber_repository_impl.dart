import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/chamber/domain/entities/chamber_status.dart';
import 'package:dashboard/src/features/chamber/domain/repositories/chamber_repository.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_command_client.dart';

final class ChamberRepositoryImpl implements ChamberRepository {
  final OrchestratorCommandClient _client;

  ChamberRepositoryImpl({required OrchestratorCommandClient client})
    : _client = client;

  @override
  Future<Result<ChamberStatus>> getStatus() async {
    final result = await _client.sendCommand('chamber.status_get');
    return result.when(
      success: (value) => Success(ChamberStatus.fromPayload(value.payload)),
      failure: FailureResult.new,
    );
  }

  @override
  Future<Result<SensorReadResult>> readTemperature(String deviceId) async {
    final result = await _client.sendCommand(
      'device.temperature.read',
      payload: {'device_id': deviceId},
    );
    return result.when(
      success: (value) =>
          Success(_readResult(value.payload, valueKey: 'temperature_celsius')),
      failure: FailureResult.new,
    );
  }

  @override
  Future<Result<SensorReadResult>> readPressure(String deviceId) async {
    final result = await _client.sendCommand(
      'device.pressure.read',
      payload: {'device_id': deviceId},
    );
    return result.when(
      success: (value) =>
          Success(_readResult(value.payload, valueKey: 'pressure_kpa')),
      failure: FailureResult.new,
    );
  }

  @override
  Future<Result<void>> setRelay(
    String deviceId,
    String capabilityId,
    bool on,
  ) async {
    final result = await _client.sendCommand(
      'device.relay.set',
      payload: {'device_id': deviceId, 'capability_id': capabilityId, 'on': on},
    );
    return result.when(
      success: (_) => const Success(null),
      failure: FailureResult.new,
    );
  }

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
    final result = await _client.sendCommand(
      'control.temperature.upsert',
      payload: {
        'rule_id': 'main-air-temperature-fan',
        'chamber_id': 'main',
        'enabled': enabled,
        'mode': 'cooling',
        'sensor': {
          'device_id': sensorDeviceId,
          'capability_id': sensorCapabilityId,
        },
        'actuator': {
          'device_id': actuatorDeviceId,
          'capability_id': actuatorCapabilityId,
        },
        'min_celsius': minCelsius,
        'max_celsius': maxCelsius,
      },
    );
    return result.when(
      success: (value) =>
          Success(ChamberControlRule.fromPayload(value.payload)),
      failure: FailureResult.new,
    );
  }

  @override
  Future<Result<void>> setTemperatureControlEnabled(bool enabled) async {
    final result = await _client.sendCommand(
      'control.temperature.set_enabled',
      payload: {'enabled': enabled},
    );
    return result.when(
      success: (_) => const Success(null),
      failure: FailureResult.new,
    );
  }

  SensorReadResult _readResult(
    Map<String, Object?> payload, {
    required String valueKey,
  }) {
    return SensorReadResult(
      value: _double(payload[valueKey]),
      rawMeasuredValue: _int(payload['raw_measured_value']),
      accepted: payload['accepted'] is bool
          ? payload['accepted'] as bool
          : false,
      resultDelivery: payload['result_delivery']?.toString(),
    );
  }

  double? _double(Object? value) {
    final parsed = value is num
        ? value.toDouble()
        : value is String
        ? double.tryParse(value)
        : null;
    return parsed;
  }

  int? _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
