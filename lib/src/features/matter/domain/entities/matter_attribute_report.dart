final class MatterAttributeReport {
  final int nodeId;
  final int endpointId;
  final int clusterId;
  final int attributeId;
  final String value;

  const MatterAttributeReport({
    required this.nodeId,
    required this.endpointId,
    required this.clusterId,
    required this.attributeId,
    required this.value,
  });
}
