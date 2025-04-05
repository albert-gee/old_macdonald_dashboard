import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'dart:convert';

import 'cluster.dart';

Future<List<Cluster>> loadClusters() async {
  final assetManifest = await rootBundle.loadString('AssetManifest.json');
  final Map<String, dynamic> manifestMap = json.decode(assetManifest);

  final clusterPaths = manifestMap.keys
      .where((path) => path.startsWith('assets/clusters/') && path.endsWith('.xml'))
      .toList();

  List<Cluster> clusters = [];

  for (final path in clusterPaths) {
    final xmlString = await rootBundle.loadString(path);
    final document = XmlDocument.parse(xmlString);

    final clusterElement = document.getElement('cluster');
    final clusterId = clusterElement?.getAttribute('id') ?? '';
    final clusterName = clusterElement?.getAttribute('name') ?? '';

    final attributes = clusterElement
        ?.findAllElements('attribute')
        .map((element) => Attribute(
      id: element.getAttribute('id') ?? '',
      name: element.getAttribute('name') ?? '',
    ))
        .toList() ?? [];

    clusters.add(Cluster(id: clusterId, name: clusterName, attributes: attributes));
  }

  return clusters;
}
