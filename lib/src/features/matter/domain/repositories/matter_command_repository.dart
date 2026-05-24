import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_attribute_read_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_attribute_subscribe_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_cluster_command_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_controller_init_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_pair_ble_thread_request.dart';
import 'package:dashboard/src/features/orchestrator/domain/entities/orchestrator_command_result.dart';

abstract interface class MatterCommandRepository {
  Future<Result<OrchestratorCommandResult>> initializeController(
    MatterControllerInitRequest request,
  );

  Future<Result<OrchestratorCommandResult>> pairBleThread(
    MatterPairBleThreadRequest request,
  );

  Future<Result<OrchestratorCommandResult>> invokeClusterCommand(
    MatterClusterCommandRequest request,
  );

  Future<Result<OrchestratorCommandResult>> readAttribute(
    MatterAttributeReadRequest request,
  );

  Future<Result<OrchestratorCommandResult>> subscribeAttribute(
    MatterAttributeSubscribeRequest request,
  );
}
