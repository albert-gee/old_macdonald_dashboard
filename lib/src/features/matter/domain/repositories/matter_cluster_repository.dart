import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_cluster.dart';

abstract interface class MatterClusterRepository {
  Future<Result<List<MatterCluster>>> loadClusters();
}
