final class ChamberStatus {
  final double? temperatureCelsius;
  final double? pressureKpa;
  final bool? relayOn;
  final String? temperatureDeviceId;
  final String? pressureDeviceId;
  final String? relayDeviceId;

  const ChamberStatus({
    this.temperatureCelsius,
    this.pressureKpa,
    this.relayOn,
    this.temperatureDeviceId,
    this.pressureDeviceId,
    this.relayDeviceId,
  });

  factory ChamberStatus.fromPayload(Map<String, Object?> payload) {
    return ChamberStatus(
      temperatureCelsius: _double(payload['temperature_celsius']),
      pressureKpa: _double(payload['pressure_kpa']),
      relayOn: payload['relay_on'] is bool ? payload['relay_on'] as bool : null,
      temperatureDeviceId: payload['temperature_device_id']?.toString(),
      pressureDeviceId: payload['pressure_device_id']?.toString(),
      relayDeviceId: payload['relay_device_id']?.toString(),
    );
  }
}

double? _double(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
