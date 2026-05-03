part of 'wifi_sta_connection_bloc.dart';

sealed class WifiStaConnectionEvent extends Equatable {
  const WifiStaConnectionEvent();
}

final class WifiStaConnectionConnectRequested extends WifiStaConnectionEvent {
  final String ssid;
  final String password;

  const WifiStaConnectionConnectRequested(this.ssid, this.password);

  @override
  List<Object> get props => [ssid, password];
}
