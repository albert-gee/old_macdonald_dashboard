part of 'wifi_sta_status_bloc.dart';

abstract class WifiStaStatusEvent extends Equatable {
  const WifiStaStatusEvent();

  @override
  List<Object> get props => [];
}

class WifiStaStatusChanged extends WifiStaStatusEvent {
  final String status;

  const WifiStaStatusChanged(this.status);

  @override
  List<Object> get props => [status];
}