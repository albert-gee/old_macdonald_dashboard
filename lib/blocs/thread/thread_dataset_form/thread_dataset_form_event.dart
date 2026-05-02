import 'package:equatable/equatable.dart';

abstract class ThreadDatasetInitFormEvent extends Equatable {
  const ThreadDatasetInitFormEvent();

  @override
  List<Object?> get props => [];
}

class ThreadDatasetInitSubmitted extends ThreadDatasetInitFormEvent {
  final int threadChannel;
  final int panId;
  final String networkName;
  final String extendedPanId;
  final String meshLocalPrefix;
  final String networkKey;
  final String pskc;

  const ThreadDatasetInitSubmitted({
    required int channel,
    required this.panId,
    required this.networkName,
    required this.extendedPanId,
    required this.meshLocalPrefix,
    required this.networkKey,
    required this.pskc,
  }) : threadChannel = channel;

  @override
  List<Object?> get props => [
        threadChannel,
        panId,
        networkName,
        extendedPanId,
        meshLocalPrefix,
        networkKey,
        pskc,
      ];
}
