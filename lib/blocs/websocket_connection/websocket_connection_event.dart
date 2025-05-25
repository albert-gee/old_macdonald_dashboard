part of 'websocket_connection_bloc.dart';

/// Base class for all WebSocket connection events.
sealed class WebsocketConnectionEvent extends Equatable {
  const WebsocketConnectionEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when a WebSocket connection is requested.
///
/// This is typically initiated by the user or the UI layer.
final class WebsocketConnectionConnectRequested extends WebsocketConnectionEvent {
  /// The WebSocket URI to connect to (e.g. wss://192.168.4.1/ws).
  final String wsUri;

  const WebsocketConnectionConnectRequested(this.wsUri);

  @override
  List<Object?> get props => [wsUri];
}

/// Event triggered when a WebSocket disconnection is requested.
///
/// Typically initiated by the user.
final class WebsocketConnectionDisconnectRequested extends WebsocketConnectionEvent {
  const WebsocketConnectionDisconnectRequested();
}

/// Event emitted when the WebSocket connection is successfully established.
///
/// This event is typically used to update the UI or trigger subsequent actions
final class WebsocketConnectionConnected extends WebsocketConnectionEvent {
  const WebsocketConnectionConnected();
}

/// Event emitted when the WebSocket has been fully disconnected.
///
/// This may occur due to user action, server-side closure, or error handling.
final class WebsocketConnectionDisconnected extends WebsocketConnectionEvent {
  const WebsocketConnectionDisconnected();
}
