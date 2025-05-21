part of 'websocket_connection_bloc.dart';

sealed class WebsocketConnectionState extends Equatable {
  const WebsocketConnectionState();

  @override
  List<Object?> get props => [];
}

final class WebsocketConnectionConnectingState extends WebsocketConnectionState {}

final class WebsocketConnectionConnectedState extends WebsocketConnectionState {}

final class WebsocketConnectionDisconnectedState extends WebsocketConnectionState {}

final class WebsocketConnectionErrorState extends WebsocketConnectionState {
  final String message;

  const WebsocketConnectionErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
