part of 'websocket_connection_bloc.dart';

sealed class WebsocketConnectionEvent extends Equatable {
  const WebsocketConnectionEvent();
}

final class WebsocketConnectionConnectingEvent extends WebsocketConnectionEvent {
  final String wsUri;

  const WebsocketConnectionConnectingEvent(this.wsUri);

  @override
  List<Object> get props => [wsUri];
}

final class WebsocketConnectionDisconnectingEvent extends WebsocketConnectionEvent {
  const WebsocketConnectionDisconnectingEvent();

  @override
  List<Object> get props => [];
}

final class WebsocketConnectionDisconnectedEvent extends WebsocketConnectionEvent {
  const WebsocketConnectionDisconnectedEvent();

  @override
  List<Object> get props => [];
}
