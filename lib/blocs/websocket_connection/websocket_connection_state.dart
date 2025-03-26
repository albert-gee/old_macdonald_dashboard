part of 'websocket_connection_bloc.dart';

sealed class WebsocketConnectionState extends Equatable {
  const WebsocketConnectionState();
}

final class WebsocketConnectionConnectingState extends WebsocketConnectionState {
  @override
  List<Object> get props => [];
}

final class WebsocketConnectionConnectedState extends WebsocketConnectionState {
  @override
  List<Object> get props => [];
}

final class WebsocketConnectionDisconnectedState extends WebsocketConnectionState {
  @override
  List<Object> get props => [];
}

final class WebsocketConnectionErrorState extends WebsocketConnectionState {
  final String message;

  const WebsocketConnectionErrorState(this.message);

  @override
  List<Object> get props => [message];
}