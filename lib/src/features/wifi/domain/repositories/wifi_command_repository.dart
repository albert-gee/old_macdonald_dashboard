import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_command_result.dart';
import 'package:dashboard/src/features/wifi/domain/entities/wifi_sta_credentials.dart';

abstract interface class WifiCommandRepository {
  Future<Result<OrchestratorCommandResult>> connectSta(
    WifiStaCredentials credentials,
  );
}
