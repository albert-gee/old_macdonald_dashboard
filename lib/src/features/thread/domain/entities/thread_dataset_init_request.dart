final class ThreadDatasetInitRequest {
  final int channel;
  final int panId;
  final String networkName;
  final String extendedPanId;
  final String meshLocalPrefix;
  final String networkKey;
  final String pskc;

  const ThreadDatasetInitRequest({
    required this.channel,
    required this.panId,
    required this.networkName,
    required this.extendedPanId,
    required this.meshLocalPrefix,
    required this.networkKey,
    required this.pskc,
  });
}
