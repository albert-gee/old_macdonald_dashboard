part of 'wifi_sta_connect_bloc.dart';

sealed class WifiStaConnectEvent extends Equatable {
  const WifiStaConnectEvent();
}

final class WifiStaConnectSendEvent extends WifiStaConnectEvent {
  final String ssid;
  final String password;

  const WifiStaConnectSendEvent(this.ssid, this.password);

  @override
  List<Object> get props => [ssid, password];
}
