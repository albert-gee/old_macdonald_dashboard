abstract class IThreadCommandService {
  Future<void> sendThreadEnableCommand();
  Future<void> sendThreadDisableCommand();

  Future<void> sendThreadDatasetInitCommand({
    required int channel,
    required int panId,
    required String networkName,
    required String extendedPanId,
    required String meshLocalPrefix,
    required String networkKey,
    required String pskc,
  });
}
