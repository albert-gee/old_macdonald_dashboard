final class MatterPairBleThreadRequest {
  final String nodeId;
  final String setupCode;
  final String discriminator;

  const MatterPairBleThreadRequest({
    required this.nodeId,
    required this.setupCode,
    required this.discriminator,
  });
}
