import 'package:equatable/equatable.dart';

class ThreadActiveDatasetState extends Equatable {
  final int activeTimestamp;
  final String networkName;
  final String extendedPanId;
  final String meshLocalPrefix;
  final int panId;
  final int channel;

  const ThreadActiveDatasetState({
    required this.activeTimestamp,
    required this.networkName,
    required this.extendedPanId,
    required this.meshLocalPrefix,
    required this.panId,
    required this.channel,
  });

  factory ThreadActiveDatasetState.initial() => const ThreadActiveDatasetState(
    activeTimestamp: 0,
    networkName: '',
    extendedPanId: '',
    meshLocalPrefix: '',
    panId: 0,
    channel: 0,
  );

  ThreadActiveDatasetState copyWith({
    int? activeTimestamp,
    String? networkName,
    String? extendedPanId,
    String? meshLocalPrefix,
    int? panId,
    int? channel,
  }) {
    return ThreadActiveDatasetState(
      activeTimestamp: activeTimestamp ?? this.activeTimestamp,
      networkName: networkName ?? this.networkName,
      extendedPanId: extendedPanId ?? this.extendedPanId,
      meshLocalPrefix: meshLocalPrefix ?? this.meshLocalPrefix,
      panId: panId ?? this.panId,
      channel: channel ?? this.channel,
    );
  }

  @override
  List<Object> get props =>
      [activeTimestamp, networkName, extendedPanId, meshLocalPrefix, panId, channel];
}
