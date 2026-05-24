import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/chamber/domain/entities/chamber_status.dart';

abstract interface class ChamberRepository {
  Future<Result<ChamberStatus>> getStatus();
  Future<Result<double>> readTemperature(String deviceId);
  Future<Result<double>> readPressure(String deviceId);
  Future<Result<void>> setRelay(String deviceId, bool on);
}
