import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_command_result.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_command_client.dart';
import 'package:dashboard/src/features/wifi/domain/entities/wifi_sta_credentials.dart';
import 'package:dashboard/src/features/wifi/domain/repositories/wifi_command_repository.dart';

final class WifiCommandRepositoryImpl implements WifiCommandRepository {
  final OrchestratorCommandClient _client;

  WifiCommandRepositoryImpl({required OrchestratorCommandClient client})
    : _client = client;

  @override
  Future<Result<OrchestratorCommandResult>> connectSta(
    WifiStaCredentials credentials,
  ) {
    return _client.sendCommand(
      'wifi.sta_connect',
      payload: {'ssid': credentials.ssid, 'password': credentials.password},
    );
  }
}
