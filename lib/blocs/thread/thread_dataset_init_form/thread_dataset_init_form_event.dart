import 'package:equatable/equatable.dart';

abstract class ThreadDatasetInitFormEvent extends Equatable {
  const ThreadDatasetInitFormEvent();

  @override
  List<Object?> get props => [];
}

class ThreadDatasetInitSubmitted extends ThreadDatasetInitFormEvent {
  final int channel;
  final int panId;
  final String networkName;
  final String extendedPanId;
  final String meshLocalPrefix;
  final String networkKey;
  final String pskc;

  const ThreadDatasetInitSubmitted({
    required this.channel,
    required this.panId,
    required this.networkName,
    required this.extendedPanId,
    required this.meshLocalPrefix,
    required this.networkKey,
    required this.pskc,
  });

  @override
  List<Object?> get props => [
    channel,
    panId,
    networkName,
    extendedPanId,
    meshLocalPrefix,
    networkKey,
    pskc,
  ];
}
