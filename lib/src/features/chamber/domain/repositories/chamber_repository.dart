import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/chamber/domain/entities/chamber_status.dart';

abstract interface class ChamberRepository {
  Future<Result<ChamberStatus>> getStatus();
  Future<Result<SensorReadResult>> readTemperature(String deviceId);
  Future<Result<SensorReadResult>> readPressure(String deviceId);
  Future<Result<void>> setRelay(String deviceId, bool on);
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
