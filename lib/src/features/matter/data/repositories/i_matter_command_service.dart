abstract class IMatterCommandService {
  Future<void> initializeController({
    required int nodeId,
    required int fabricId,
    required int listenPort,
  });

  Future<void> pairBleThread({
    required String nodeId,
    required String setupCode,
    required String discriminator,
  });

  Future<void> invokeClusterCommand({
    required String destinationId,
    required int endpointId,
    required int clusterId,
    required int commandId,
    required String commandData,
  });

  Future<void> readAttribute({
    required String nodeId,
    required int endpointId,
    required int clusterId,
    required int attributeId,
  });

  Future<void> subscribeAttribute({
    required String nodeId,
    required int endpointId,
    required int clusterId,
    required int attributeId,
    required int minInterval,
    required int maxInterval,
  });
}
