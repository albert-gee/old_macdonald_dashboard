final class MatterAttributeReadRequest {
  final String nodeId;
  final int endpointId;
  final int clusterId;
  final int attributeId;

  const MatterAttributeReadRequest({
    required this.nodeId,
    required this.endpointId,
    required this.clusterId,
    required this.attributeId,
  });
}
