import 'package:dashboard/src/core/errors/app_failure.dart';
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
  Future<Result<double>> readTemperature(String deviceId) async {
    final result = await _client.sendCommand(
      'device.temperature.read',
      payload: {'device_id': deviceId},
    );
    return result.when(
      success: (value) => _doubleResult(value.payload['temperature_celsius']),
      failure: FailureResult.new,
    );
  }

  @override
  Future<Result<double>> readPressure(String deviceId) async {
    final result = await _client.sendCommand(
      'device.pressure.read',
      payload: {'device_id': deviceId},
    );
    return result.when(
      success: (value) => _doubleResult(value.payload['pressure_kpa']),
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

  Result<double> _doubleResult(Object? value) {
    final parsed = value is num
        ? value.toDouble()
        : value is String
        ? double.tryParse(value)
        : null;
    if (parsed == null) {
      return const FailureResult(UnknownFailure('Missing numeric value.'));
    }
    return Success(parsed);
  }
}
