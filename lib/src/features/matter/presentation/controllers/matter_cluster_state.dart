import 'package:dashboard/src/features/matter/domain/entities/matter_cluster.dart';

final class MatterClusterState {
  final bool loading;
  final List<MatterCluster> clusters;
  final String? message;

  const MatterClusterState({
    this.loading = false,
    this.clusters = const [],
    this.message,
  });
}
