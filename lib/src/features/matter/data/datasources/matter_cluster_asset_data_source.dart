import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

import 'package:dashboard/src/core/errors/app_failure.dart';
import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/matter/data/dtos/matter_cluster_dto.dart';

final class MatterClusterAssetDataSource {
  Future<Result<List<MatterClusterDto>>> loadClusters() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final clusterPaths = manifest
          .listAssets()
          .where((path) =>
              path.startsWith('assets/clusters/') && path.endsWith('.xml'))
          .toList()
        ..sort();

      final clusters = <MatterClusterDto>[];
      for (final path in clusterPaths) {
        final xmlString = await rootBundle.loadString(path);
        clusters.add(_parseCluster(xmlString));
      }

      return Success(clusters);
    } catch (error) {
      return FailureResult(AssetLoadFailure('Unable to load Matter clusters.'));
    }
  }

  MatterClusterDto _parseCluster(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final clusterElement = document.getElement('cluster');
    final attributes = clusterElement
            ?.findAllElements('attribute')
            .map((element) => MatterAttributeDto(
                  id: element.getAttribute('id') ?? '',
                  name: element.getAttribute('name') ?? '',
                ))
            .toList() ??
        const <MatterAttributeDto>[];

    return MatterClusterDto(
      id: clusterElement?.getAttribute('id') ?? '',
      name: clusterElement?.getAttribute('name') ?? '',
      attributes: attributes,
    );
  }
}
