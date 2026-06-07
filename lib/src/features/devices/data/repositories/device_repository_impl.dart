import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/devices/domain/entities/device_record.dart';
import 'package:dashboard/src/features/devices/domain/repositories/device_repository.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_command_result.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_command_client.dart';

final class DeviceRepositoryImpl implements DeviceRepository {
  final OrchestratorCommandClient _client;

  DeviceRepositoryImpl({required OrchestratorCommandClient client})
    : _client = client;

  @override
  Future<Result<List<DeviceRecord>>> listDevices() async {
    final result = await _client.sendCommand('device.list');
    return result.when(
      success: (value) {
        final devices = value.payload['devices'];
        if (devices is! List) return const Success(<DeviceRecord>[]);
        return Success(devices.whereType<Map>().map(_record).toList());
      },
      failure: FailureResult.new,
    );
  }

  @override
  Future<Result<DeviceRecord>> getDevice(String deviceId) async {
    final result = await _client.sendCommand(
      'device.get',
      payload: {'device_id': deviceId},
    );
    return _single(result);
  }

  @override
  Future<Result<void>> refreshDevice(String deviceId) async {
    final result = await _client.sendCommand(
      'device.refresh',
      payload: {'device_id': deviceId},
    );
    return result.when(
      success: (_) => const Success(null),
      failure: FailureResult.new,
    );
  }

  @override
  Future<Result<void>> renameDevice(String deviceId, String label) async {
    final result = await _client.sendCommand(
      'device.rename',
      payload: {'device_id': deviceId, 'label': label},
    );
    return result.when(
      success: (_) => const Success(null),
      failure: FailureResult.new,
    );
  }

  @override
  Future<Result<void>> removeDevice(String deviceId) async {
    final result = await _client.sendCommand(
      'device.remove',
      payload: {'device_id': deviceId},
    );
    return result.when(
      success: (_) => const Success(null),
      failure: FailureResult.new,
    );
  }

  Result<DeviceRecord> _single(Result<OrchestratorCommandResult> result) {
    return result.when(
      success: (value) {
        final device = value.payload['device'];
        if (device is Map) return Success(_record(device));
        return Success(DeviceRecord.fromJson(value.payload));
      },
      failure: FailureResult.new,
    );
  }

  DeviceRecord _record(Map<dynamic, dynamic> json) {
    return DeviceRecord.fromJson(
      json.map((key, value) => MapEntry(key.toString(), value)),
    );
  }
}
