import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_attribute_read_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_attribute_subscribe_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_cluster_command_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_controller_init_request.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_pair_ble_thread_request.dart';

abstract interface class MatterCommandRepository {
  Future<Result<void>> initializeController(
      MatterControllerInitRequest request);

  Future<Result<void>> pairBleThread(MatterPairBleThreadRequest request);

  Future<Result<void>> invokeClusterCommand(
      MatterClusterCommandRequest request);

  Future<Result<void>> readAttribute(MatterAttributeReadRequest request);

  Future<Result<void>> subscribeAttribute(
    MatterAttributeSubscribeRequest request,
  );
}
