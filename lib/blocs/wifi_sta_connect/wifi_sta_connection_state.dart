part of 'wifi_sta_connection_bloc.dart';

sealed class WifiStaConnectionState extends Equatable {
  const WifiStaConnectionState();

  @override
  List<Object?> get props => [];
}

final class WifiStaConnectInitialState extends WifiStaConnectionState {
  const WifiStaConnectInitialState();
}

final class WifiStaConnectLoadingState extends WifiStaConnectionState {
  const WifiStaConnectLoadingState();
}

final class WifiStaConnectSuccessState extends WifiStaConnectionState {
  const WifiStaConnectSuccessState();
}

final class WifiStaConnectFailureState extends WifiStaConnectionState {
  final String error;

  const WifiStaConnectFailureState(this.error);

  @override
  List<Object> get props => [error];
}
