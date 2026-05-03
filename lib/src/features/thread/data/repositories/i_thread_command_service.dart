abstract class IThreadCommandService {
  Future<void> sendThreadEnableCommand();
  Future<void> sendThreadDisableCommand();
  Future<void> sendThreadStatusGetCommand();
  Future<void> sendThreadAttachedGetCommand();
  Future<void> sendThreadRoleGetCommand();
  Future<void> sendThreadActiveDatasetGetCommand();
  Future<void> sendThreadUnicastAddressesGetCommand();
  Future<void> sendThreadMulticastAddressesGetCommand();
  Future<void> sendThreadBorderRouterInitCommand();
  Future<void> sendThreadBorderRouterDeinitCommand();

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
