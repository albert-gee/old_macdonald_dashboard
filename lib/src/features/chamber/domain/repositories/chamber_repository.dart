import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/chamber/domain/entities/chamber_status.dart';

abstract interface class ChamberRepository {
  Future<Result<ChamberStatus>> getStatus();
  Future<Result<SensorReadResult>> readTemperature(
    String deviceId,
    String capabilityId,
  );
  Future<Result<SensorReadResult>> readPressure(
    String deviceId,
    String capabilityId,
  );
  Future<Result<void>> setRelay(String deviceId, String capabilityId, bool on);
  Future<Result<ChamberControlRule>> saveTemperatureRule({
    required String sensorDeviceId,
    required String sensorCapabilityId,
    required String actuatorDeviceId,
    required String actuatorCapabilityId,
    required double minCelsius,
    required double maxCelsius,
    required bool enabled,
  });
  Future<Result<void>> setTemperatureControlEnabled(bool enabled);
}

final class SensorReadResult {
  final double? value;
  final int? rawMeasuredValue;
  final bool accepted;
  final String? resultDelivery;

  const SensorReadResult({
    this.value,
    this.rawMeasuredValue,
    this.accepted = false,
    this.resultDelivery,
  });

  bool get waitingForReport =>
      accepted && resultDelivery == 'matter.attribute_report' && value == null;
}

final class ChamberControlRule {
  final bool configured;
  final bool enabled;
  final double minCelsius;
  final double maxCelsius;
  final String state;
  final String? lastError;

  const ChamberControlRule({
    required this.configured,
    required this.enabled,
    required this.minCelsius,
    required this.maxCelsius,
    required this.state,
    this.lastError,
  });

  factory ChamberControlRule.fromPayload(Map<String, Object?> payload) {
    return ChamberControlRule(
      configured: payload['configured'] is bool
          ? payload['configured'] as bool
          : true,
      enabled: payload['enabled'] is bool ? payload['enabled'] as bool : false,
      minCelsius: _double(payload['min_celsius']) ?? 24,
      maxCelsius: _double(payload['max_celsius']) ?? 28,
      state: payload['state']?.toString() ?? 'disabled',
      lastError: payload['last_error']?.toString(),
    );
  }
}

double? _double(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
