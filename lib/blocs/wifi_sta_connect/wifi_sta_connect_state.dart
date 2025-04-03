part of 'wifi_sta_connect_bloc.dart';

sealed class WifiStaConnectState extends Equatable {
  const WifiStaConnectState();

  @override
  List<Object?> get props => [];
}

final class WifiStaConnectInitialState extends WifiStaConnectState {
  const WifiStaConnectInitialState();
}

final class WifiStaConnectLoadingState extends WifiStaConnectState {
  const WifiStaConnectLoadingState();
}

final class WifiStaConnectSuccessState extends WifiStaConnectState {
  const WifiStaConnectSuccessState();
}

final class WifiStaConnectFailureState extends WifiStaConnectState {
  final String error;

  const WifiStaConnectFailureState(this.error);

  @override
  List<Object> get props => [error];
}
