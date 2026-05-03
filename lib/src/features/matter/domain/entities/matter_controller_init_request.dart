final class MatterControllerInitRequest {
  final int nodeId;
  final int fabricId;
  final int listenPort;

  const MatterControllerInitRequest({
    required this.nodeId,
    required this.fabricId,
    required this.listenPort,
  });
}
