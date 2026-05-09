final class MatterClusterCommandRequest {
  final String destinationId;
  final int endpointId;
  final int clusterId;
  final int commandId;
  final String commandData;

  const MatterClusterCommandRequest({
    required this.destinationId,
    required this.endpointId,
    required this.clusterId,
    required this.commandId,
    required this.commandData,
  });
}
