import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/devices/domain/entities/device_record.dart';

abstract interface class DeviceRepository {
  Future<Result<List<DeviceRecord>>> listDevices();
  Future<Result<DeviceRecord>> getDevice(String deviceId);
  Future<Result<void>> refreshDevice(String deviceId);
  Future<Result<void>> renameDevice(String deviceId, String label);
  Future<Result<void>> removeDevice(String deviceId);
}
