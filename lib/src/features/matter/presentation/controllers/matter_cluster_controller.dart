import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/matter/domain/repositories/matter_cluster_repository.dart';
import 'matter_cluster_state.dart';

final class MatterClusterController extends StateNotifier<MatterClusterState> {
  final MatterClusterRepository _repository;

  MatterClusterController({required MatterClusterRepository repository})
      : _repository = repository,
        super(const MatterClusterState(loading: true)) {
    load();
  }

  Future<void> load() async {
    state = const MatterClusterState(loading: true);
    final result = await _repository.loadClusters();
    state = switch (result) {
      Success(value: final clusters) => MatterClusterState(clusters: clusters),
      FailureResult(failure: final failure) =>
        MatterClusterState(message: failure.message),
    };
  }
}
