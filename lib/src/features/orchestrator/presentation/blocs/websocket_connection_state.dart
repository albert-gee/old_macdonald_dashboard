part of 'websocket_connection_bloc.dart';

/// Base class for all WebSocket connection states.
sealed class WebsocketConnectionState extends Equatable {
  const WebsocketConnectionState();

  @override
  List<Object?> get props => [];
}

/// WebSocket is disconnected.
final class WebsocketConnectionDisconnectedState
    extends WebsocketConnectionState {}

/// WebSocket is in the process of connecting.
final class WebsocketConnectionConnectingState
    extends WebsocketConnectionState {}

/// WebSocket connection is established.
final class WebsocketConnectionConnectedState
    extends WebsocketConnectionState {}

/// WebSocket connection failure.
///
/// Contains an error message that describes the issue.
final class WebsocketConnectionErrorState extends WebsocketConnectionState {
  final String message;

  const WebsocketConnectionErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
