import 'package:equatable/equatable.dart';

class ThreadActiveDatasetUpdated extends Equatable {
  final int activeTimestamp;
  final String networkName;
  final String extendedPanId;
  final String meshLocalPrefix;
  final int panId;
  final int channel;

  const ThreadActiveDatasetUpdated({
    required this.activeTimestamp,
    required this.networkName,
    required this.extendedPanId,
    required this.meshLocalPrefix,
    required this.panId,
    required this.channel,
  });

  @override
  List<Object> get props =>
      [activeTimestamp, networkName, extendedPanId, meshLocalPrefix, panId, channel];
}
