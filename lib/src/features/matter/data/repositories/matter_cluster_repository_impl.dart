import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/matter/data/datasources/matter_cluster_asset_data_source.dart';
import 'package:dashboard/src/features/matter/data/mappers/matter_cluster_mapper.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_cluster.dart';
import 'package:dashboard/src/features/matter/domain/repositories/matter_cluster_repository.dart';

final class MatterClusterRepositoryImpl implements MatterClusterRepository {
  final MatterClusterAssetDataSource _dataSource;
  final MatterClusterMapper _mapper;

  MatterClusterRepositoryImpl({
    required MatterClusterAssetDataSource dataSource,
    MatterClusterMapper mapper = const MatterClusterMapper(),
  })  : _dataSource = dataSource,
        _mapper = mapper;

  @override
  Future<Result<List<MatterCluster>>> loadClusters() async {
    final result = await _dataSource.loadClusters();
    return switch (result) {
      Success(value: final dtos) => Success(dtos.map(_mapper.map).toList()),
      FailureResult(failure: final failure) => FailureResult(failure),
    };
  }
}
