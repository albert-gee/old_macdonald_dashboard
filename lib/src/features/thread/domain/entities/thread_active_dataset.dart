final class ThreadActiveDataset {
  final int activeTimestamp;
  final String networkName;
  final String extendedPanId;
  final String meshLocalPrefix;
  final int panId;
  final int channel;

  const ThreadActiveDataset({
    this.activeTimestamp = 0,
    this.networkName = '',
    this.extendedPanId = '',
    this.meshLocalPrefix = '',
    this.panId = 0,
    this.channel = 0,
  });

  bool get isEmpty =>
      activeTimestamp == 0 &&
      networkName.isEmpty &&
      extendedPanId.isEmpty &&
      meshLocalPrefix.isEmpty &&
      panId == 0 &&
      channel == 0;
}
