import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/thread/domain/entities/thread_dataset_init_request.dart';

abstract interface class ThreadCommandRepository {
  Future<Result<void>> enable();
  Future<Result<void>> disable();
  Future<Result<void>> refreshStatus();
  Future<Result<void>> refreshAttachment();
  Future<Result<void>> refreshRole();
  Future<Result<void>> refreshActiveDataset();
  Future<Result<void>> refreshUnicastAddresses();
  Future<Result<void>> refreshMulticastAddresses();
  Future<Result<void>> initBorderRouter();
  Future<Result<void>> deinitBorderRouter();
  Future<Result<void>> initDataset(ThreadDatasetInitRequest request);
}
