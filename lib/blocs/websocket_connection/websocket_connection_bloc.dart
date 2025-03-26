import 'dart:async';

import 'package:dashboard/network/websocket.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dashboard/models/websocket_message.dart';

part 'websocket_connection_event.dart';

part 'websocket_connection_state.dart';

class WebsocketConnectionBloc
    extends Bloc<WebsocketConnectionEvent, WebsocketConnectionState> {
  final WebSocketMessageParser messageParser;
  final Websocket websocket;
  final void Function(String, String) onPrintMessageToLog;
  final void Function(WebSocketMessage) onMessageReceived;
  final void Function() onWebsocketDone;
  StreamSubscription? _messageSubscription;

  WebsocketConnectionBloc({
    required this.messageParser,
    required this.websocket,
    required this.onPrintMessageToLog,
    required this.onMessageReceived,
    required this.onWebsocketDone,
  }) : super(WebsocketConnectionDisconnectedState()) {
    on<WebsocketConnectionConnectingEvent>(_onConnecting);
    on<WebsocketConnectionDisconnectingEvent>(_onDisconnecting);
    on<WebsocketConnectionDisconnectedEvent>(_onDisconnected);
  }

  Future<void> _onConnecting(
    WebsocketConnectionConnectingEvent event,
    Emitter<WebsocketConnectionState> emit,
  ) async {
    emit(WebsocketConnectionConnectingState());
    onPrintMessageToLog('info', 'Connecting to WebSocket...');

    try {
      final isConnected = await connect();
      if (isConnected) {
        emit(WebsocketConnectionConnectedState());
        onPrintMessageToLog('info', 'WebSocket connected successfully');
      } else {
        emit(const WebsocketConnectionErrorState(
            'Failed to establish connection'));
        onPrintMessageToLog('error', 'WebSocket connection failed');
      }
    } catch (e) {
      emit(WebsocketConnectionErrorState('Connection error: $e'));
      onPrintMessageToLog('error', 'Connection error: $e');
    }
  }

  Future<void> _onDisconnecting(
    WebsocketConnectionDisconnectingEvent event,
    Emitter<WebsocketConnectionState> emit,
  ) async {
    onPrintMessageToLog('info', 'Disconnecting from WebSocket...');
    await _disconnect();
    emit(WebsocketConnectionDisconnectedState());
  }

  void _onDisconnected(
    WebsocketConnectionDisconnectedEvent event,
    Emitter<WebsocketConnectionState> emit,
  ) {
    onPrintMessageToLog('info', 'WebSocket disconnected');
    emit(WebsocketConnectionDisconnectedState());
  }

  Future<bool> connect() async {
    if (websocket.isConnected()) return true;

    int reconnectAttempts = 0;
    const maxReconnectAttempts = 5;

    while (reconnectAttempts < maxReconnectAttempts) {
      try {
        await websocket.connect();
        if (websocket.isConnected()) {
          print('WebSocket connected');

          // Cancel previous subscription if it exists
          await _messageSubscription?.cancel();

          // Set up a new listener
          websocket.listen(
            onMessageReceived: (message) => _handleRawMessage(message),
            onDone: () {
              onWebsocketDone();
              add(const WebsocketConnectionDisconnectedEvent());
            },
            onError: (error) {
              onPrintMessageToLog('error', 'WebSocket error: $error');
              add(const WebsocketConnectionDisconnectedEvent());
            },
          );
          return true;
        }
      } catch (e) {
        onPrintMessageToLog('warning', 'Connection attempt ${reconnectAttempts + 1} failed: $e');
      }
      reconnectAttempts++;
    }
    return false;
  }

  Future<void> _disconnect() async {
    await _messageSubscription?.cancel();
    _messageSubscription = null;
    await websocket.disconnect();
  }

  void _handleRawMessage(String message) {
    print('_handleRawMessage: $message');

    try {
      final WebSocketMessage parsedMessage = messageParser.parse(message);

      onMessageReceived(parsedMessage);
    } on MessageParseException catch (e) {
      onPrintMessageToLog('error', 'Message parse error: ${e.message}');
    } catch (e) {
      onPrintMessageToLog('error', 'Unexpected message handling error: $e');
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
