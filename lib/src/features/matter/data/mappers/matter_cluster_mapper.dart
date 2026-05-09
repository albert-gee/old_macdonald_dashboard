import 'package:dashboard/src/features/matter/data/dtos/matter_cluster_dto.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_attribute.dart';
import 'package:dashboard/src/features/matter/domain/entities/matter_cluster.dart';

final class MatterClusterMapper {
  const MatterClusterMapper();

  MatterCluster map(MatterClusterDto dto) {
    return MatterCluster(
      id: dto.id,
      name: dto.name,
      attributes: dto.attributes
          .map((attribute) => MatterAttribute(
                id: attribute.id,
                name: attribute.name,
              ))
          .toList(),
    );
  }
}
