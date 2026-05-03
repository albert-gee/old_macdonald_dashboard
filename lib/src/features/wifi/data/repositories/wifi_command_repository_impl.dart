import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/orchestrator/data/dtos/outbound_orchestrator_command_dto.dart';
import 'package:dashboard/src/features/orchestrator/domain/repositories/orchestrator_connection_repository.dart';
import 'package:dashboard/src/features/wifi/domain/entities/wifi_sta_credentials.dart';
import 'package:dashboard/src/features/wifi/domain/repositories/wifi_command_repository.dart';

final class WifiCommandRepositoryImpl implements WifiCommandRepository {
  final OrchestratorConnectionRepository _connectionRepository;

  WifiCommandRepositoryImpl({
    required OrchestratorConnectionRepository connectionRepository,
  }) : _connectionRepository = connectionRepository;

  @override
  Future<Result<void>> connectSta(WifiStaCredentials credentials) {
    return _send(
      const OutboundOrchestratorCommandDto(
        action: 'wifi.sta_connect',
      ),
      payload: {
        'ssid': credentials.ssid,
        'password': credentials.password,
      },
    );
  }

  Future<Result<void>> _send(
    OutboundOrchestratorCommandDto command, {
    Map<String, Object?>? payload,
  }) {
    final dto = OutboundOrchestratorCommandDto(
      action: command.action,
      payload: payload,
    );
    return _connectionRepository.sendRaw(dto.toJsonString());
  }
}
