import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_command_result.dart';
import 'package:dashboard/src/features/thread/domain/entities/thread_dataset_init_request.dart';

abstract interface class ThreadCommandRepository {
  Future<Result<OrchestratorCommandResult>> enable();
  Future<Result<OrchestratorCommandResult>> disable();
  Future<Result<OrchestratorCommandResult>> refreshStatus();
  Future<Result<OrchestratorCommandResult>> refreshAttachment();
  Future<Result<OrchestratorCommandResult>> refreshRole();
  Future<Result<OrchestratorCommandResult>> refreshActiveDataset();
  Future<Result<OrchestratorCommandResult>> refreshUnicastAddresses();
  Future<Result<OrchestratorCommandResult>> refreshMulticastAddresses();
  Future<Result<OrchestratorCommandResult>> initBorderRouter();
  Future<Result<OrchestratorCommandResult>> deinitBorderRouter();
  Future<Result<OrchestratorCommandResult>> initDataset(
    ThreadDatasetInitRequest request,
  );
}
