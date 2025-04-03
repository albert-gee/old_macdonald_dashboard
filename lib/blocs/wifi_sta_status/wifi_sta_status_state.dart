part of 'wifi_sta_status_bloc.dart';

abstract class WifiStaStatusState extends Equatable {
  const WifiStaStatusState();

  @override
  List<Object> get props => [];
}

class WifiStaStatusInitial extends WifiStaStatusState {}

class WifiStaStatusUpdated extends WifiStaStatusState {
  final String status;

  const WifiStaStatusUpdated(this.status);

  @override
  List<Object> get props => [status];
}