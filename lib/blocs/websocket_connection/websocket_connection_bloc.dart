import 'dart:async';
import 'package:dashboard/websocket/websocket_client.dart';
import 'package:dashboard/websocket/websocket_message_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

part 'websocket_connection_event.dart';
part 'websocket_connection_state.dart';

/// BLoC for managing the WebSocket connection lifecycle.
///
/// Handles connect, disconnect, and reconnection attempts,
/// and emits state updates reflecting connection status or errors.
class WebsocketConnectionBloc
    extends Bloc<WebsocketConnectionEvent, WebsocketConnectionState> {
  final WebSocketClient websocket;
  final WebSocketMessageHandler messageHandler;

  StreamSubscription? _streamSub;
  String? _currentUrl;

  static const int _maxConnectionAttempts = 5;
  static const Duration _connectTimeout = Duration(seconds: 5);
  static const Duration _retryDelay = Duration(seconds: 2);

  final Logger _logger = Logger();

  WebsocketConnectionBloc({
    required this.websocket,
    required this.messageHandler,
  }) : super(WebsocketConnectionDisconnectedState()) {
    on<WebsocketConnectionConnectRequested>(_onConnectRequested);
    on<WebsocketConnectionDisconnectRequested>(_onDisconnectRequested);
    on<WebsocketConnectionDisconnected>(_onDisconnected);
  }

  /// Initiates connection to a WebSocket endpoint with retry and timeout.
  Future<void> _onConnectRequested(
      WebsocketConnectionConnectRequested event,
      Emitter<WebsocketConnectionState> emit,
      ) async {
    emit(WebsocketConnectionConnectingState());
    _currentUrl = event.wsUri;

    try {
      final connected = await _tryConnect(_currentUrl!);
      if (connected) {
        emit(WebsocketConnectionConnectedState());
        _logger.i('WebSocket connected to $_currentUrl');
      } else {
        emit(const WebsocketConnectionErrorState('Failed to connect'));
        _logger.w('WebSocket connection failed after $_maxConnectionAttempts attempts');
      }
    } catch (e, stack) {
      emit(WebsocketConnectionErrorState('Error: $e'));
      _logger.e('Unhandled WebSocket connection error', error: e, stackTrace: stack);
    }
  }

  /// Handles manual disconnect requests and cleans up resources.
  Future<void> _onDisconnectRequested(
      WebsocketConnectionDisconnectRequested event,
      Emitter<WebsocketConnectionState> emit,
      ) async {
    await _disconnect();
    emit(WebsocketConnectionDisconnectedState());
    _logger.i('WebSocket disconnected by user');
  }

  /// Handles disconnect events triggered by the WebSocket (onDone/onError).
  void _onDisconnected(
      WebsocketConnectionDisconnected event,
      Emitter<WebsocketConnectionState> emit,
      ) {
    emit(WebsocketConnectionDisconnectedState());
    _logger.w('WebSocket disconnected unexpectedly');
  }

  /// Attempts to establish a connection with retry and timeout logic.
  ///
  /// Returns true if connected, false otherwise.
  Future<bool> _tryConnect(String url) async {
    if (websocket.isConnected) return true;

    for (var attempt = 1; attempt <= _maxConnectionAttempts; attempt++) {
      try {
        final success = await websocket
            .connect(url: url, rootCAAsset: 'assets/rootCA.pem')
            .timeout(_connectTimeout);

        if (success) {
          await _streamSub?.cancel();
          websocket.listen(
            onMessage: _handleMessage,
            onDone: () => add(const WebsocketConnectionDisconnected()),
            onError: (_) => add(const WebsocketConnectionDisconnected()),
          );
          return true;
        }
      } on TimeoutException {
        _logger.w('Connection timed out (attempt $attempt)');
      } catch (e, stack) {
        _logger.e('Connection error (attempt $attempt)', error: e, stackTrace: stack);
      }

      await Future.delayed(_retryDelay);
    }

    return false;
  }

  /// Cancels any open streams and closes the WebSocket connection.
  Future<void> _disconnect() async {
    await _streamSub?.cancel();
    _streamSub = null;
    await websocket.disconnect();
  }

  /// Parses incoming WebSocket messages and handles errors.
  void _handleMessage(String message) {
    _logger.i('Received message: $message');

    try {
      messageHandler.handle(message);
    } on MessageParseException catch (e) {
      _logger.e('Message parse error: ${e.message}');
    } catch (e, stack) {
      _logger.e('Unexpected message handling error', error: e, stackTrace: stack);
    }
  }

  /// Ensures resources are cleaned up when the BLoC is closed.
  @override
  Future<void> close() async {
    await _streamSub?.cancel();
    return super.close();
  }
}
