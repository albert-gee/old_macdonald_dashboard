final class MatterAttributeSubscribeRequest {
  final String nodeId;
  final int endpointId;
  final int clusterId;
  final int attributeId;
  final int minInterval;
  final int maxInterval;

  const MatterAttributeSubscribeRequest({
    required this.nodeId,
    required this.endpointId,
    required this.clusterId,
    required this.attributeId,
    required this.minInterval,
    required this.maxInterval,
  });
}
