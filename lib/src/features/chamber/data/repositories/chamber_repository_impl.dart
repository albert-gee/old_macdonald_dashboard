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
  Future<Result<void>> setRelay(String deviceId, bool on) async {
    final result = await _client.sendCommand(
      'device.relay.set',
      payload: {'device_id': deviceId, 'on': on},
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
